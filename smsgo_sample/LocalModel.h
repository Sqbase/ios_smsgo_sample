//
//  LocalModel.h
//  smsgo_sample
//
//  Created by Cloud on 2015/4/17.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalModel : NSObject

//singleton
+ (id)sharedInstance;

- (NSMutableArray *)loadArrayFromLocalPListFile;
- (void)saveToLocalPlistFile:(NSMutableArray *)dictArray;

@end
