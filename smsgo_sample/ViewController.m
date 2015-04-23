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
#pragma mark - SYSTEM method
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!numberArray) {
        numberArray = [NSMutableArray new];
    }
    
    //Touch self.view disable Keyboard
    UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    //ViewModel init
    _mainPageMV = [MainPageMV sharedInstance];
    
    [_mainPageMV addObserver:self
                 forKeyPath:@"pointString"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    
    [_mainPageMV addObserver:self
                  forKeyPath:@"isSendSuccess"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark KVO Method
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"pointString"]){
        [self showAlertWithSuccess:YES Content:[NSString stringWithFormat:@"Left Point : %@", [change objectForKey:@"new"]]];
        
    }else if ([keyPath isEqualToString:@"isSendSuccess"]){
        if ([[change objectForKey:@"new"] integerValue] == 1) {
            [self showAlertWithSuccess:YES Content:@"Message Sent to Server Successfully."];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        
    }
}

#pragma mark - Custom Utils Method
- (BOOL)checkUserAndPasswd{
    if (_userNameField.text.length == 0 || _passwordField.text.length == 0) {
        [self showAlertWithSuccess:NO Content:@"Check Username or Password."];
        return NO;
    }else{
        return YES;
    }
}
-(void)showAlertWithSuccess:(BOOL)isSucceed Content:(NSString *)message{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:isSucceed ? @"Result" : @"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
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

#pragma mark - UI Action
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [_numberField resignFirstResponder];
    [_userNameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_numberTextView resignFirstResponder];
    [_contentTextView resignFirstResponder];
    
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
        [self showAlertWithSuccess:NO Content:@"Enter the Number."];
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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_mainPageMV QueryPointWithUser:_userNameField.text
                               password:_passwordField.text];
    }
}

- (IBAction)sendPress:(id)sender {
    if (numberArray.count == 0 || !numberArray) {
        [self showAlertWithSuccess:NO Content:@"Must have number in List" ];
    }else{
        if (_contentTextView.text.length == 0) {
            [self showAlertWithSuccess:NO Content:@"Must have Message text."];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [_mainPageMV sendSingleSMSWithUsername:_userNameField.text
                                          password:_passwordField.text
                                           numbers:numberArray
                                           content:_contentTextView.text];
        }
    }
}



@end
