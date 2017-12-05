//
//  SettingsViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/13/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "SettingsViewController.h"
#import "NetworkController.h"
#import "AppDelegate.h"
@import Firebase;

@interface SettingsViewController ()
@property (strong, nonatomic) NSMutableDictionary *userDetails;
@end

@implementation SettingsViewController {
    NSString *userEmail;
    NSString *userPassword;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"Settings"
                        parameters:nil];
}

- (void)initialSetup {

    self.constraintHeightViewDevide.constant = self.constraintHeightViewDevide.constant  / [UIScreen mainScreen].scale;
    userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];
    [self.labelEmail setText:userEmail];

}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)buttonMenu:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController resizeMenuViewControllerToSize:(CGSize)self.view.frame.size];
    
    // Present the view controller
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)buttonPushNotifications:(UIButton *)sender {
    [self performSegueWithIdentifier:kSettingsViewControllerToPushNotificationsViewControllerSegue sender:self];
}

- (IBAction)buttonChangePassword:(UIButton *)sender {
    [self performSegueWithIdentifier:kSettingsViewControllerToPasswordViewControllerSegue sender:self];
}

- (IBAction)buttonPositionsSettings:(UIButton *)sender {
    [self performSegueWithIdentifier:kSettingsViewControllerToPositionsSettingsViewControllerSegue sender:self];
}
@end
