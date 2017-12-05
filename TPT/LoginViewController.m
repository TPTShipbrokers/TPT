//
//  LoginViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/13/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "NetworkController.h"
#import <OneSignal/OneSignal.h>

@interface LoginViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (strong, nonatomic) NSMutableDictionary *userDetails;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialSetup {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    if (iPhone6) {
        self.verticalSpaceContraintLabelEmail.constant = self.verticalSpaceContraintLabelEmail.constant  +60;
    }
    else if (iphone5) {
        self.verticalSpaceContraintLabelEmail.constant = self.verticalSpaceContraintLabelEmail.constant - 40;
    }
    else if (iPhone6Plus) {
        self.verticalSpaceContraintLabelEmail.constant = self.verticalSpaceContraintLabelEmail.constant  +130;
    }
    else {
        self.verticalSpaceContraintLabelEmail.constant = self.verticalSpaceContraintLabelEmail.constant - 125;
      }
    
    self.responseData = [[NSMutableData alloc]init];
    self.textFieldEmail.delegate = self;
    self.textFieldPassword.delegate = self;
    UIColor *color = [UIColor colorWithRed: 255/255.0 green: 255/255.0 blue: 255/255.0 alpha: 1.0];

    if ([self.textFieldEmail respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.textFieldEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email address" attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    if ([self.textFieldPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.textFieldPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    }
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MailComposeControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)buttonSignIn:(UIButton *)sender {
    NSString *username = self.textFieldEmail.text;
    NSString *password = self.textFieldPassword.text;
    if (username.length < 1 && password.length < 1) {
        [SVProgressHUD showErrorWithStatus:@"To login, please, fill in both email and password field."];
        return;
    }
    else {
        
        [SVProgressHUD showWithStatus:@"Signing in..."];
        [[NetworkController sharedInstance]signInUserWithUsername:username andPassword:password andResponseBlock:^(BOOL success, id response) {
            if (success) {
                
                [[NetworkController sharedInstance]getUserDetailsWithResponseBlock:^(BOOL success, id response) {
                    if (success) {
                        //get user details after login
                        self.userDetails = [[NSMutableDictionary alloc] initWithDictionary:response];
                        NSString *userName = [self.userDetails objectForKey:@"first_name"];
                        NSString *userLastname = [self.userDetails objectForKey:@"last_name"];
                        NSString *fullName = [NSString stringWithFormat:@"%@ %@",userName, userLastname];
                        NSNumber *userId = [self.userDetails objectForKey:@"user_id"];
                        
                        //Save PFInstalation to Parse
                        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                        if (currentInstallation && currentInstallation.objectId) {
                            currentInstallation[@"email"] = username;
                            [currentInstallation saveInBackground];
                        }
                        //[OneSignal sendTag:@"email" value:userName];
                        //OVDE
                        
                        //get user profile picture
                        NSString *imageUrl = [self.userDetails objectForKey:@"profile_picture"];
                        NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",imageUrl];
                        NSURL *imageURL = [NSURL URLWithString:fullUrl];
                        
                        //Save user details to NSUserdefaults
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                            [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"userPicture"];
                            [[NSUserDefaults standardUserDefaults] setObject:fullName forKey:@"userFullName"];
                            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"UserEmailAddress"];
                            [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"UserPassword"];
                            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userIdentifier"];
                            [[NSUserDefaults standardUserDefaults] setObject:fullUrl forKey:@"userProfilePictureUrlString"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggedIn" object:nil];
                        });
                    }
                    else {
                        NSLog(@"%@", response);
                    }
                }];
                [Settings setLoginStatus:YES];
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]) userLoggedIn];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"There was an error logging You in. Please, try again."];
                NSLog(@"%@", response);
            }
        }];
    }
}

- (IBAction)buttonContact:(UIButton *)sender {
    // Email Subject
    NSString *emailTitle = @"Account request";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"admin@tunept.com"];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}
@end
