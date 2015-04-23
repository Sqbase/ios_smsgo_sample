//
//  MainPageMV.h
//  smsgo_sample
//
//  Created by Cloud on 2015/4/22.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Network.h"
#import "LocalModel.h"

@interface MainPageMV : NSObject

typedef void (^DataCompletion)(BOOL succeed, id result,  NSError *error);

//singleton
+ (id)sharedInstance;

@property (strong, nonatomic) NSString *pointString;
@property (nonatomic) BOOL isSendSuccess;


- (void)QueryPointWithUser:(NSString *)username password:(NSString *)password;
- (void)sendSingleSMSWithUsername:(NSString *)username password:(NSString *)password numbers:(NSArray *)numbers content:(NSString *)content;

@end
