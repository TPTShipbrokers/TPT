//
//  PasswordViewController.h
//  TPT
//
//  Created by Bosko Barac on 10/29/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface PasswordViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFieldOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRetypePassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;


- (IBAction)buttonSave:(UIButton *)sender;

@end
