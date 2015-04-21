//
//  LocalModel.m
//  smsgo_sample
//
//  Created by Cloud on 2015/4/17.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import "LocalModel.h"

@implementation LocalModel

//singleton
+ (id)sharedInstance{
    static LocalModel *sharedLocalModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocalModel = [[self alloc] init];
    });
    
    return sharedLocalModel;
}

- (id)init {
    if (self = [super init]) {
        NSLog(@"init LocalModel method");
    }
    return self;
}

//Load from Local
- (NSMutableArray *)loadArrayFromLocalPListFile{
    
    //取得plist檔案路徑
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/Data.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //判斷plist檔案存在才讀取
    if ([fileManager fileExistsAtPath: filePath]) {
        NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        return data;
    
    }else{
        NSMutableArray *data = [NSMutableArray new];
        return data;
    }

}

//Save in Local
- (void)saveToLocalPlistFile:(NSMutableArray *)dataArray{
    //取得plist檔案路徑
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/Data.plist"];
        
    //將plist檔案存入Document
    if ([dataArray writeToFile:filePath atomically: YES]) {
        NSLog(@"資料寫入成功！");
    } else {
        NSLog(@"資料寫入失敗！");
    }

}

@end
