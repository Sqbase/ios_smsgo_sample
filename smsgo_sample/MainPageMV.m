//
//  MainPageMV.m
//  smsgo_sample
//
//  Created by Cloud on 2015/4/22.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import "MainPageMV.h"

@implementation MainPageMV


//singleton
+ (id)sharedInstance{
    static MainPageMV *sharedSelf = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSelf = [[self alloc] init];
    });
    
    return sharedSelf;
}

- (id)init {
    if (self = [super init]) {
        NSLog(@"init Network method");
        self.pointString = @"000";
    }
    return self;
}

- (void)QueryPointWithUser:(NSString *)username password:(NSString *)password{
    __block NSString *pointString = @"";
    
    [[Network sharedInstance] queryPointWithUserName:username
                                            password:password
                                          completion:^(BOOL succeed, id result, NSError *error) {
                                              if (succeed) {
                                                  NSString *point = [[[[result objectForKey:@"results"] objectForKey:@"result"] lastObject] objectForKey:@"point"];
                                                  pointString = point;
                                                  self.pointString = point;
                                                  
                                              }else{
                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"ok"
                                                                                        otherButtonTitles:nil, nil];
                                                  [alert show];
                                              }
                                          }];
    
}

- (void)sendSingleSMSWithUsername:(NSString *)username password:(NSString *)password numbers:(NSArray *)numbers content:(NSString *)content{
    
    [[Network sharedInstance] sendSMSWithAuthByUser:username
                                           Password:password
                                          ToNumbers:numbers
                                             Smbody:content
                                         completion:^(BOOL succeed, id result, NSError *error) {
                                             if (succeed) {
                                                 self.isSendSuccess = YES;
                                                 NSMutableDictionary *dataDict = [NSMutableDictionary new];
                                                 [dataDict setObject:@1 forKey:@"succeed"];
                                                 [dataDict setObject:numbers forKey:@"SendNumber"];
                                                 [dataDict setObject:@{@"user" : username,
                                                                       @"passwd" : password}
                                                              forKey:@"user"];
                                                 [dataDict setObject:[NSDate date] forKey:@"date"];
                                                 [dataDict setObject:[result objectForKey:@"result"] forKey:@"result"];
            
                                                 [self fetchToLocalFileWithDict:dataDict];
            
                                             }else{
                                                 self.isSendSuccess = NO;
                                                 
                                                 NSMutableDictionary *dataDict = [NSMutableDictionary new];
                                                 [dataDict setObject:@0 forKey:@"succeed"];
                                                 [dataDict setObject:numbers forKey:@"SendNumber"];
                                                 [dataDict setObject:@{@"user" : username,
                                                                       @"passwd" : password}
                                                              forKey:@"user"];
                                                 [dataDict setObject:[NSDate date] forKey:@"date"];
                                                 [dataDict setObject:[result objectForKey:@"result"] forKey:@"result"];
            
                                                 [self fetchToLocalFileWithDict:dataDict];
                                                 
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                 message:error.localizedDescription
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"ok"
                                                                                       otherButtonTitles:nil, nil];
                                                 [alert show];
                                             }
    }];
}

- (void)fetchToLocalFileWithDict:(NSDictionary *)dataDict{
    LocalModel *localModel = [LocalModel sharedInstance];
    NSMutableArray *dataArray = [localModel loadArrayFromLocalPListFile];
    //NSLog(@"%@", dataArray);
    [dataArray addObject:dataDict];
    [localModel saveToLocalPlistFile:dataArray];
}
@end
