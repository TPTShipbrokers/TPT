//
//  OutstandingClaimsViewController.m
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "OutstandingClaimsViewController.h"
#import "NetworkController.h"
#import "AppDelegate.h"
#import "EmailEnquiryViewController.h"
@import Firebase;

@interface OutstandingClaimsViewController ()
@property (strong, nonatomic) NSMutableArray *items;
@end

@implementation OutstandingClaimsViewController {
    NSMutableArray *statusesForStatemant;
    NSData *reportData;
    NSMutableArray *datesForStatuses;
    NSString * resultConditions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"OutstandingClaims"
                        parameters:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    
    statusesForStatemant = [[NSMutableArray alloc]init];
    datesForStatuses = [[NSMutableArray alloc]init];
    self.items = [[NSMutableArray alloc] init];
    
    [self.labelname setText:self.shipName];
    [self.labelStatus setText:self.status];
    [self.labelTime setText:self.date];
    [self getCharteringDetails];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];
}

#pragma mark - NSNotificationDelegate

- (void)refreshPages:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        [self getCharteringDetails];
    }
}

#pragma mark - Private

- (void) getCharteringDetails {
    [[NetworkController sharedInstance]getCharteringDetailsForCharterId:self.charterId WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            //self.details = response;
            NSDictionary *dict = response;
            NSDictionary *dict2 = [dict objectForKey:@"data"];
            
            //Set the statuses
            NSMutableArray *formated = [[NSMutableArray alloc] init];
            
            NSArray *claims = [[NSArray alloc]initWithArray:[dict2 objectForKey:@"claims"]];
            NSLog(@"%@", claims);
            if (claims.count > 0) {
                for (NSDictionary *claimDict in claims) {

                    NSString *description = [claimDict objectForKey:@"description"];
                    if (description && ![description isKindOfClass:[NSNull class]]) {
                        [self.textView setText:description];
                    }
                }
            }
            else {
                [self.textView setText:@"No claims items reported."];
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
                [SVProgressHUD showErrorWithStatus:@"Error.\nCan't get data for outstanding claim."];
                NSLog(@"%@", response);
            }
            NSLog(@"%@", response);
        }
    }];
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kOutstandingClaimsViewControllerToEmailEnquiryViewControllerSegue]) {
        EmailEnquiryViewController *destViewController = segue.destinationViewController;
        destViewController.shipName = self.shipName;
        destViewController.isComingFromClaims = [NSNumber numberWithBool:YES];
    }
}

- (IBAction)buttonRequest:(UIButton *)sender {
    [self performSegueWithIdentifier:kOutstandingClaimsViewControllerToEmailEnquiryViewControllerSegue sender:self];
}
@end
