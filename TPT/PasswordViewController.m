//
//  PasswordViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/29/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "PasswordViewController.h"
#import "NetworkController.h"
#import "AppDelegate.h"
@import Firebase;

@interface PasswordViewController ()

@end

@implementation PasswordViewController {
    NSString *userPassword;
    NSString *userEmail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"PasswordChange"
                        parameters:nil];
}

- (void)initialSetup {
    // Setup textfield delegate
    self.textFieldNewPassword.delegate = self;
    self.textFieldOldPassword.delegate = self;
    self.textFieldRetypePassword.delegate = self;
    
    // Setup Textfield placeholders
    if ([self.textFieldOldPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed: 74/255.0 green: 74/255.0 blue: 74/255.0 alpha: 1.0];
        self.textFieldOldPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Existing password" attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    if ([self.textFieldNewPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed: 74/255.0 green: 74/255.0 blue: 74/255.0 alpha: 1.0];
        self.textFieldNewPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter new password" attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    if ([self.textFieldRetypePassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed: 74/255.0 green: 74/255.0 blue: 74/255.0 alpha: 1.0];
        self.textFieldRetypePassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Re-type new password" attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    // Get user email and password from NSUserDefaults
    userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
    userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (IBAction)buttonSave:(UIButton *)sender {
    NSString *userOldPassword = self.textFieldOldPassword.text;
    NSString *newPassword = self.textFieldNewPassword.text;
    NSString *reEnteredPassword = self.textFieldRetypePassword.text;
    
    if (![userOldPassword isEqualToString:userPassword]) {
        [SVProgressHUD showErrorWithStatus:@"Error: The current password you entered doesn't match the password from database."];
        return;
    }
    else {
        if (![newPassword isEqualToString:reEnteredPassword]) {
            [SVProgressHUD showErrorWithStatus:@"Error: New entered password must match the re-typed password."];
            return;
        }
        else if (newPassword.length == 0 || reEnteredPassword == 0) {
            [SVProgressHUD showErrorWithStatus:@"Error: Password must contain at least 1 character."];
            return;
        }
        else {
            [SVProgressHUD showWithStatus:@"Saving your changes..."];

            [[NetworkController sharedInstance]changeUserDetailsWithEmail:userEmail password:newPassword status:@"online" WithResponseBlock:^(BOOL success, id response) {
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
                [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:@"UserPassword"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
}
@end
