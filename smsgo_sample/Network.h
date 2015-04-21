//
//  Network.h
//  smsgo_sample
//
//  Created by Cloud on 2015/4/15.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>


typedef NS_ENUM(NSInteger, encodingType){
    Big5,
    ASCII,
    USC2,
    PBIG5,
    PASCII,
    LBIG5,
    LASCII,
    LUCS2,
    PUSH
};

typedef void (^DataCompletion)(BOOL succeed, id result,  NSError *error);

@interface Network : NSObject

//singleton
+ (id)sharedInstance;

//Network Method
- (void) sendSMSWithAuthByUser:(NSString *)username
                      Password:(NSString *)password
                     ToNumbers:(NSArray *)numbersArray
                        Smbody:(NSString *)smbody
                    completion:(DataCompletion)completion;

- (void) sendSMSWithAuthByUser:(NSString *)username
                      Password:(NSString *)password
                     ToNumbers:(NSArray *)numbersArray
                  EncodingType:(encodingType)encoding
                        Smbody:(NSString *)smbody
                       Dlvtime:(NSDate *)dlvtime
                        wapurl:(NSString *)wapurl
                      replyurl:(NSString *)replyurl
                     replydays:(NSString *)replydays
                      response:(NSString *)response
                    completion:(DataCompletion)completion;


//Query SMS Status
- (void) querySingleSMSStatusWithUserName:(NSString *)username
                                 password:(NSString *)password
                                    msgID:(NSString *)msgID
                                  dstaddr:(NSString *)dstaddr
                               completion:(DataCompletion)completion;


- (void) queryMultiSMSStatusWithUserName:(NSString *)username
                                password:(NSString *)password
                                   msgID:(NSArray *)msgID
                                 dstaddr:(NSArray *)dstaddr
                              completion:(DataCompletion)completion;

//Query Point
- (void) queryPointWithUserName:(NSString *)username
                       password:(NSString *)password
                     completion:(DataCompletion)completion;


//Cancel Schedule SMS
- (void) cancelScheduledSMSUserName:(NSString *)username
                           password:(NSString *)password
                              msgID:(NSString *)msgID
                         completion:(DataCompletion)completion;

@end
