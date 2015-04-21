//
//  ViewController.m
//  smsgo_sample
//
//  Created by Cloud on 2015/4/15.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!numberArray) {
        numberArray = [NSMutableArray new];
    }
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    // Do any additional setup after loading the view, typically from a nib
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [_numberField resignFirstResponder];
    [_userNameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_numberTextView resignFirstResponder];
    [_contentTextView resignFirstResponder];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendContantFromAddressBook:(NSNotification *)noti{
    for (NSString *number in noti.object) {
        NSString *oriString = _numberTextView.text;
        NSString *addString = [oriString stringByAppendingString:[NSString stringWithFormat:@"%@\r\n", [number stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
        _numberTextView.text = addString;
        [numberArray addObject:[number stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    }
    NSLog(@"%@", numberArray);
}

- (IBAction)addNumber:(id)sender {
    if (![_numberField.text isEqualToString:@""]) {
        NSString *numberText =  _numberField.text;
        NSString *oriString = _numberTextView.text;
        NSString *addString = [oriString stringByAppendingString:[NSString stringWithFormat:@"%@\r\n", numberText]];
        _numberTextView.text = addString;
        _numberField.text = @"";
        [numberArray addObject:numberText];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Enter the Number." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    [_numberField resignFirstResponder];
}

- (IBAction)showAddressBook:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendContantFromAddressBook:)
                                                 name:@"sendContant"
                                               object:nil];
    
    
    KBContactsSelectionViewController *vc = [KBContactsSelectionViewController contactsSelectionViewControllerWithConfiguration:^(KBContactsSelectionConfiguration *configuration) {
        configuration.mode = KBContactsSelectionModeMessages;
        configuration.shouldShowNavigationBar = NO;
        configuration.tintColor = [UIColor colorWithRed:11.0/255 green:211.0/255 blue:24.0/255 alpha:1];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clear:(id)sender {
    _numberTextView.text = @"";
    numberArray = [NSMutableArray new];
}

- (IBAction)queryPoint:(id)sender {
    if ([self checkUserAndPasswd]) {
        [[Network sharedInstance] queryPointWithUserName:_userNameField.text
                                                password:_passwordField.text
                                              completion:^(BOOL succeed, id result, NSError *error) {
                                                  if (succeed) {
                                                      NSString *point = [[[[result objectForKey:@"results"] objectForKey:@"result"] lastObject] objectForKey:@"point"];
                                                      NSLog(@"%@", point);
                                                      
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result"
                                                                                                      message:[NSString stringWithFormat:@"Left Point : %@", point]
                                                                                                     delegate:nil
                                                                                            cancelButtonTitle:@"ok"
                                                                                            otherButtonTitles:nil, nil];
                                                      [alert show];
                                                      
                                                  }else{
                                                      NSLog(@"%@", error.localizedDescription);
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                      message:error.localizedDescription
                                                                                                     delegate:nil
                                                                                            cancelButtonTitle:@"ok"
                                                                                            otherButtonTitles:nil, nil];
                                                      [alert show];
                                                  }
                                              }];
    }
}

- (IBAction)sendPress:(id)sender {
    
    Network *network = [Network sharedInstance];
    if (numberArray.count == 0 || !numberArray) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Must have number in List" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        if (_contentTextView.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Must have Message text." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [network sendSMSWithAuthByUser:_userNameField.text Password:_passwordField.text ToNumbers:numberArray Smbody:_contentTextView.text completion:^(BOOL succeed, id result, NSError *error) {
                if (succeed) {
                    
                    LocalModel *localModel = [LocalModel sharedInstance];
                    NSMutableArray *dataArray = [localModel loadArrayFromLocalPListFile];
                    NSLog(@"%@", dataArray);
                    NSMutableDictionary *dataDict = [NSMutableDictionary new];
                    [dataDict setObject:@1 forKey:@"succeed"];
                    [dataDict setObject:numberArray forKey:@"SendNumber"];
                    [dataDict setObject:@{@"user" : _userNameField.text,
                                          @"passwd" : _passwordField.text}
                                 forKey:@"user"];
                    [dataDict setObject:[NSDate date] forKey:@"date"];
                    [dataDict setObject:[result objectForKey:@"result"] forKey:@"result"];
                    [dataArray addObject:dataDict];
                    NSLog(@"%@", dataArray);
                    
                    [localModel saveToLocalPlistFile:dataArray];
                    
                    NSLog(@"succeed : %@", result);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Message Sent to Server Successfully." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                    [alert show];
                
                }else{
                    
                    LocalModel *localModel = [LocalModel sharedInstance];
                    NSMutableArray *dataArray = [localModel loadArrayFromLocalPListFile];
                    NSLog(@"ori array : %@", dataArray);
                    NSMutableDictionary *dataDict = [NSMutableDictionary new];
                    [dataDict setObject:@0 forKey:@"succeed"];
                    [dataDict setObject:numberArray forKey:@"SendNumber"];
                    [dataDict setObject:@{@"user" : _userNameField.text,
                                          @"passwd" : _passwordField.text}
                                 forKey:@"user"];
                    [dataDict setObject:[NSDate date] forKey:@"date"];
                    [dataDict setObject:[result objectForKey:@"result"] forKey:@"result"];
                    [dataArray addObject:dataDict];
                    NSLog(@"%@", dataArray);
                    
                    [localModel saveToLocalPlistFile:dataArray];
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    NSLog(@"error : %@", error.localizedDescription);
                    NSLog(@"error : %@", result);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"ok"
                                                          otherButtonTitles:nil, nil];
                    
                    [alert show];
                }
            }];
        }
    }
}

- (BOOL)checkUserAndPasswd{
    if (_userNameField.text.length == 0 || _passwordField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Check Username or Password." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }else{
        return YES;
    }
}

@end
