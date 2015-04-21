//
//  HistoryVC.m
//  smsgo_sample
//
//  Created by Cloud on 2015/4/17.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import "HistoryVC.h"

@interface HistoryVC ()

@end

@implementation HistoryVC

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    _dataArray = (NSArray *)[[LocalModel sharedInstance] loadArrayFromLocalPListFile];
    _dataArray = [[_dataArray reverseObjectEnumerator] allObjects];
    NSLog(@"%@", _dataArray);
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _indexSet = [NSMutableIndexSet indexSet];
    
    _queryButton = [[UIBarButtonItem alloc] initWithTitle:@"Query"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(pressQuery)];

    self.clearsSelectionOnViewWillAppear = YES;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pressQuery{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSArray *queryArray = [_dataArray objectsAtIndexes:_indexSet];
    NSLog(@"%@", queryArray);
    
    NSMutableArray *numArray = [NSMutableArray new];
    NSMutableArray *IDArray = [NSMutableArray new];
    
    NSString *userName = [[[queryArray firstObject] objectForKey:@"user"] objectForKey:@"user"];
    NSString *password = [[[queryArray firstObject] objectForKey:@"user"] objectForKey:@"passwd"];
    
    for (NSDictionary *dict in queryArray) {
        [numArray addObject:[NSString stringWithFormat:@"%@", [[dict objectForKey:@"SendNumber"] firstObject]]];
        [IDArray addObject:[NSString stringWithFormat:@"%@", [[dict objectForKey:@"result"] objectForKey:@"msgid"]]];
    }
    
    NSLog(@"numArray : %@", numArray);
    NSLog(@"IDArray : %@", IDArray);
    
    [[Network sharedInstance] queryMultiSMSStatusWithUserName:userName
                                                     password:password
                                                        msgID:IDArray
                                                      dstaddr:numArray
                                                   completion:^(BOOL succeed, id result, NSError *error) {
                                                       if (succeed) {
                                                           NSLog(@"%@", result);
                                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                           
                                                           NSMutableArray *successAry = [NSMutableArray new];
                                                           
                                                           for (NSDictionary *dataDict in [[result objectForKey:@"results"] objectForKey:@"result"]) {
                                                               
                                                               [successAry addObject:[NSString stringWithFormat:@"To: %@, Status: %@", [dataDict objectForKey:@"cellphone"], [dataDict     objectForKey:@"statusStr"]]];
                                                           }
                                                           
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result"
                                                                                                           message:[NSString stringWithFormat:@"%@", [successAry componentsJoinedByString:@"\r\n"]]
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                                                           
                                                           [alert show];
                                                       }else{
                                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                                                           
                                                           [alert show];
                                                           //NSLog(@"%@", error.localizedDescription);
                                                       }
    }];
    
}


#pragma mark - Table view Delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationItem.leftBarButtonItem = _queryButton;
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    if (editing) {
        self.navigationItem.leftBarButtonItem = _queryButton;
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }else{
        self.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    
    BOOL isSucceed = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"succeed"] boolValue];
    
    NSDateFormatter* df_UTF = [[NSDateFormatter alloc] init];
    [df_UTF setTimeZone:[NSTimeZone systemTimeZone]];
    [df_UTF setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSDate *date = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"date"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Sent to : %@", [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"SendNumber"] componentsJoinedByString:@","]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Date: %@  Success: %@", [df_UTF stringFromDate:date], isSucceed ? @"YES":@"NO" ];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {

        
        BOOL isSucceed = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"succeed"] boolValue];
        
        if (isSucceed) {
            [_indexSet addIndex:indexPath.row];
            [self.navigationItem.leftBarButtonItem setEnabled:_indexSet.count != 0];
            
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        BOOL isSucceed = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"succeed"] boolValue];
        
        if (isSucceed) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSString *userName = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"user"];
            NSString *passwd = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"passwd"];
            NSString *msgID = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"result"] objectForKey:@"msgid"];
            NSString *dstaddr = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"SendNumber"] objectAtIndex:0];
            //NSString *dstaddr = [[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"SendNumber"] componentsJoinedByString:@","];
            
            [[Network sharedInstance] querySingleSMSStatusWithUserName:userName
                                                              password:passwd
                                                                 msgID:msgID
                                                               dstaddr:dstaddr
                                                            completion:^(BOOL succeed, id result, NSError *error) {
                                                                if (succeed) {
                                                                    NSLog(@"%@", result);
                                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                                    NSString *sentTo = [[[[result objectForKey:@"results"] objectForKey:@"result"] firstObject] objectForKey:@"cellphone"];
                                                                    NSString *status = [[[[result objectForKey:@"results"] objectForKey:@"result"] firstObject] objectForKey:@"statusStr"];
                                                                    
                                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:[NSString stringWithFormat:@"To: %@, Status: %@", sentTo, status] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                                                                    
                                                                    [alert show];
                                                                }else{
                                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                                                                    
                                                                    [alert show];
                                                                    //NSLog(@"%@", error.localizedDescription);
                                                                }
                                                            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing) {
        [_indexSet removeIndex:indexPath.row];
        [self.navigationItem.leftBarButtonItem setEnabled:_indexSet.count != 0];
    }
}

@end
