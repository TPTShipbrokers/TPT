//
//  LoginViewController.h
//  TPT
//
//  Created by Bosko Barac on 10/13/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <MessageUI/MessageUI.h>

@interface LoginViewController : UIViewController <NSURLConnectionDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;

- (IBAction)buttonSignIn:(UIButton *)sender;
- (IBAction)buttonContact:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceContraintLabelEmail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraintTextFieldPassword;

@end
