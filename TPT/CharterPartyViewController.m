//
//  CharterPartyViewController.m
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "CharterPartyViewController.h"
#import "NetworkController.h"
#import "AppDelegate.h"
@import Firebase;

@interface CharterPartyViewController ()
@end

@implementation CharterPartyViewController {
    BOOL buttonsEnabled;
    NSString *description;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"CharterParty"
                        parameters:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    buttonsEnabled = YES;
    [self.labelShipName setText:self.shipName];
    [self.labelStatus setText:self.date];
    [self.labelDate setText:self.date];
    self.textView.delegate = self;
    [self getChertaeringDetails];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];
    
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

#pragma mark - NSNotificationDelegate

- (void)refreshPages:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        [self getChertaeringDetails];
    }
}

#pragma mark - Private

- (void)getChertaeringDetails {
    [[NetworkController sharedInstance]getCharteringDetailsForCharterId:self.charterId WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            //self.details = response;
            NSDictionary *dict = response;
            NSDictionary *dict2 = [dict objectForKey:@"data"];
            NSDictionary *charterParty = [dict2 objectForKey:@"charter_party"];
            if (charterParty && ![charterParty isKindOfClass:[NSNull class]]) {
                description = [charterParty objectForKey:@"description"];
                [self.textView setText:description];
                buttonsEnabled = YES;
            }
            else {
                buttonsEnabled = NO;
                [SVProgressHUD showErrorWithStatus:@"Error:\nThere is no charter party data at this time. Please try again later."];
            }
        }
        else {
            if ([response isKindOfClass:[NSString class]]) {
                if ([response isEqualToString:@"No internet connection."]) {
                    [SVProgressHUD showErrorWithStatus:@"Error.\nNo internet connection."];
                    NSLog(@"%@", response);
                }
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Error.\nCan't get data."];
                NSLog(@"%@", response);
            }
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonEmail:(UIButton *)sender {
    
    if (buttonsEnabled) {
        
        [SVProgressHUD showWithStatus:@"Sending email..."];
        
        NSString *saveString = [self.textView.text stringByReplacingOccurrencesOfString: @"\n" withString: @"<br>"];
        
        [[NetworkController sharedInstance] sendEmailToUserWithText:saveString fileName:@"Charter party" subject:@"TPT forwarded email" WithResponseBlock:^(BOOL success, id response) {
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"Email sent."];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Error:\n There was an eror sending email, please try again."];
            }
        }];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Error:\n There is no data to send at this time."];
    }
}
@end
