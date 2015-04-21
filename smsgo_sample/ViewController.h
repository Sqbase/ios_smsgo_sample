//
//  ViewController.h
//  smsgo_sample
//
//  Created by Cloud on 2015/4/15.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Network.h"
#import <KBContactsSelectionViewController.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "LocalModel.h"


@interface ViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>{
    NSMutableArray *numberArray;
}

//@property (strong, nonatomic)

- (void)sendContantFromAddressBook:(NSNotification *)noti;

//Interface Builder
//Action
- (IBAction)sendPress:(id)sender;
- (IBAction)addNumber:(id)sender;
- (IBAction)showAddressBook:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)queryPoint:(id)sender;

//Outlet
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextView *numberTextView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;


@end

