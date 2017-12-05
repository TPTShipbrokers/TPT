//
//  SettingsViewController.h
//  TPT
//
//  Created by Bosko Barac on 10/13/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UISwitch *switchMarket;
@property (weak, nonatomic) IBOutlet UISwitch *switchNewsLetter;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightViewDevide;


- (IBAction)buttonMenu:(UIBarButtonItem *)sender;
- (IBAction)buttonSave:(UIButton *)sender;
- (IBAction)buttonPushNotifications:(UIButton *)sender;
- (IBAction)buttonChangePassword:(UIButton *)sender;
- (IBAction)buttonPositionsSettings:(UIButton *)sender;

@end
