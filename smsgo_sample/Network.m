//
//  Network.m
//  smsgo_sample
//
//  Created by Cloud on 2015/4/15.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//
#import "Network.h"

@implementation Network

static Network *_network = nil;

//Const
NSString *const kSendSMSBaseURLDev = @"http://smscenter.smsgo.com.tw/sms_gw/sendsms.aspx?rtype=JSON";
NSString *const kSendSMSBaseURL = @"http://www.smsgo.com.tw/sms_gw/sendsms.aspx?rtype=JSON";
NSString *const kSendSMSBaseURLSSL = @"https://ssl.smsgo.com.tw/sms_gw/sendsms.aspx?rtype=JSON";

NSString *const kQuerySingleSMSSentStatusDev = @"http://smscenter.smsgo.com.tw/sms_gw/query.asp?rtype=JSON";
NSString *const kQuerySingleSMSSentStatus = @"http://www.smsgo.com.tw/sms_gw/query.asp?rtype=JSON";
NSString *const kQuerySingleSMSSentStatusSSL = @"https://ssl.smsgo.com.tw/sms_gw/query.asp?rtype=JSON";

NSString *const kQueryMultiSMSSentStatusDev = @"http://smscenter.smsgo.com.tw/sms_gw/queryBulk.asp?rtype=JSON";
NSString *const kQueryMultiSMSSentStatus = @"http://www.smsgo.com.tw/sms_gw/queryBulk.asp?rtype=JSON";
NSString *const kQueryMultiSMSSentStatusSSL = @"https://ssl.smsgo.com.tw/sms_gw/queryBulk.asp?rtype=JSON";

NSString *const kQueryPointDev = @"http://smscenter.smsgo.com.tw/sms_gw/query_point.asp?rtype=JSON";
NSString *const kQueryPoint = @"http://www.smsgo.com.tw/sms_gw/query_point.asp?rtype=JSON";
NSString *const kQueryPointSSL = @"https://ssl.smsgo.com.tw/sms_gw/query_point.asp?rtype=JSON";

NSString *const kCancelScheduledSMSDev = @"http://smscenter.smsgo.com.tw/sms_gw/sendsms_cancel.asp?rtype=JSON";
NSString *const kCancelScheduledSMS = @"http://www.smsgo.com.tw/sms_gw/sendsms_cancel.asp?rtype=JSON";
NSString *const kCancelScheduledSMSSSL = @"https://ssl.smsgo.com.tw/sms_gw/sendsms_cancel.asp?rtype=JSON";


//singleton
+ (id)sharedInstance{
    static Network *sharedNetwork = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetwork = [[self alloc] init];
    });
    
    return sharedNetwork;
}

- (id)init {
    if (self = [super init]) {
        NSLog(@"init Network method");
    }
    return self;
}

//Network Method
//send SMS
- (void) sendSMSWithAuthByUser:(NSString *)username
                      Password:(NSString *)password
                     ToNumbers:(NSArray *)numbersArray
                        Smbody:(NSString *)smbody
                    completion:(DataCompletion)completion{
    [self sendSMSWithAuthByUser:username Password:password ToNumbers:numbersArray EncodingType:Big5 Smbody:smbody Dlvtime:nil wapurl:@"" replyurl:@"" replydays:@"" response:@"" completion:completion];
}


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
                    completion:(DataCompletion)completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager POST:kSendSMSBaseURLSSL
       parameters:@{@"username":username,
                   @"password":password,
                   @"dstaddr":[numbersArray componentsJoinedByString:@","],
                   @"smbody":smbody}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSString *statusCode = [NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"result"] objectForKey:@"statuscode"]];
              
              if ([statusCode isEqualToString:@"0"]) {
                   completion(YES, responseObject, nil);
              }else{
                  NSError *err = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%@%@", @"Server Return StatusCode,", [[responseObject objectForKey:@"result"] objectForKey:@"statusstr"] ]
                                                            code:[[[responseObject objectForKey:@"result"] objectForKey:@"statuscode"] intValue]
                                                        userInfo:@{NSLocalizedDescriptionKey : [[responseObject objectForKey:@"result"] objectForKey:@"statusstr"]}];
                  completion(NO, responseObject, err);
              }
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(NO, nil, error);
    }];
    
}
//Query SMS Status
- (void) querySingleSMSStatusWithUserName:(NSString *)username
                                 password:(NSString *)password
                                    msgID:(NSString *)msgID
                                  dstaddr:(NSString *)dstaddr
                               completion:(DataCompletion)completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kQuerySingleSMSSentStatusSSL
       parameters:@{@"username" : username,
                    @"password" : password,
                    @"dstaddr" : dstaddr,
                    @"msgid" : msgID}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //NSLog(@"%@", responseObject);
              NSError *errorJson=nil;
              NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&errorJson];
              completion(YES, responseDict, nil);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(NO, nil, error);
    }];

}
//Query Multi SMS Status
- (void) queryMultiSMSStatusWithUserName:(NSString *)username
                                password:(NSString *)password
                                   msgID:(NSArray *)msgID
                                 dstaddr:(NSArray *)dstaddr
                              completion:(DataCompletion)completion{
    
    NSString *IDsString = [msgID componentsJoinedByString:@","];
    NSString *dstaddrString = [dstaddr componentsJoinedByString:@","];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:kQueryMultiSMSSentStatusSSL
       parameters:@{@"username" : username,
                    @"password" : password,
                    @"dstaddr" : dstaddrString,
                    @"msgid" : IDsString}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%@", responseObject);
              completion(YES, responseObject, nil);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(NO, nil, error);
    }];
}
//Query Point
- (void) queryPointWithUserName:(NSString *)username
                       password:(NSString *)password
                     completion:(DataCompletion)completion{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kQueryPointSSL
       parameters:@{@"username" : username,
                    @"password" : password}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSError *errorJson=nil;
              NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&errorJson];
              id statusCode = @"";
              statusCode = [NSString stringWithFormat:@"%@", [[[[responseDict objectForKey:@"results"] objectForKey:@"result"] firstObject] objectForKey:@"statuscode"]];
              NSLog(@"%@", statusCode);
              statusCode = [statusCode isEqualToString:@"(null)"] ? @"-1" : statusCode;
              
              if ([statusCode isEqualToString:@"0"]) {
                  NSLog(@"%@", responseDict);
                  NSError *err = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%@%@", @"Server Return StatusCode,", statusCode]
                                                            code:[statusCode intValue]
                                                        userInfo:@{NSLocalizedDescriptionKey : [[[[responseDict objectForKey:@"results"] objectForKey:@"result"] firstObject] objectForKey:@"statusstr"]}];
                  completion(NO, responseDict, err);
                  
                  
              }else{
                  completion(YES, responseDict, nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(NO, nil, error);
    }];
}

//Cancel Scheduled SMS
- (void) cancelScheduledSMSUserName:(NSString *)username
                           password:(NSString *)password
                              msgID:(NSString *)msgID
                         completion:(DataCompletion)completion{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:kCancelScheduledSMSSSL
       parameters:@{@"username" : username,
                    @"password" : password,
                    @"msgID" : msgID}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completion(YES, responseObject, nil);
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(NO, nil, error);
    }];
}


@end
