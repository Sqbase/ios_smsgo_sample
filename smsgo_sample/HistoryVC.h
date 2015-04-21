//
//  HistoryVC.h
//  smsgo_sample
//
//  Created by Cloud on 2015/4/17.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Network.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "LocalModel.h"

@interface HistoryVC : UITableViewController

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableIndexSet *indexSet;

@property (nonatomic, strong) UIBarButtonItem *queryButton;

@end
