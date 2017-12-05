//
//  StatemantOFFactsViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/15/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "StatemantOFFactsViewController.h"
#import "NetworkController.h"
#import "AppDelegate.h"
#import "UITextView+Placeholder.h"
@import Firebase;

@interface StatemantOFFactsViewController ()

@end

@implementation StatemantOFFactsViewController {
    NSString *latitude;
    NSString *longitude;
    NSMutableArray *statusesForStatemant;
    NSData *reportData;
    NSMutableArray *datesForStatuses;
    NSString * resultConditions;
    NSMutableArray *formated;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"StatemantOfFacts"
                        parameters:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    
    statusesForStatemant = [[NSMutableArray alloc]init];
    datesForStatuses = [[NSMutableArray alloc]init];
    
    [self.labelName setText:self.shipName];
    [self.labelStatus setText:self.status];
    [self.labelTime setText:self.date];
    self.textView.delegate = self;
    [self getDetailsForSOF];
    
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
        [self getDetailsForSOF];
    }
}

#pragma mark - Private

- (void)getDetailsForSOF {
    [[NetworkController sharedInstance]getCharteringDetailsForCharterId:self.charterId WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            //self.details = response;
            NSDictionary *dict = response;
            NSDictionary *dict2 = [dict objectForKey:@"data"];
            
            //Set the statuses
            formated = [[NSMutableArray alloc] init];
            
            NSDictionary *statuses = [dict2 objectForKey:@"statuses"];
            
            for (NSDictionary *statusDict in statuses) {
                
                NSDictionary *status = [statusDict objectForKey:@"status"];
                NSString *description = [status objectForKey:@"description"];
               // NSLog(@" ALJO %@",description);
                
                NSString *dateTime = [statusDict objectForKey:@"datetime"];
                NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
                [timeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
                [timeFormat setLocale:twentyFour];
                NSDate *dateFromString = [timeFormat dateFromString:dateTime];
                [timeFormat setDateFormat:@"HHmm"];
                NSString *theTime = [timeFormat stringFromDate:dateFromString];
                NSString *fullStatus = [NSString stringWithFormat:@"%@ hrs : %@",theTime,description];
                [formated addObject:fullStatus];
            }
            NSString *sofComments = [dict2 objectForKey:@"sof_comments"];
            resultConditions = [formated componentsJoinedByString:@"\n"];
            [self.textView setText:[NSString stringWithFormat:@"%@ \n\n %@",resultConditions, sofComments]];
            self.textView.scrollEnabled = YES;
            //[self.textView scrollRangeToVisible:[self.textView selectedRange]];
        }
        else {
            if ([response isKindOfClass:[NSString class]]) {
                if ([response isEqualToString:@"No internet connection."]) {
                    [SVProgressHUD showErrorWithStatus:@"Error.\nNo internet connection."];
                    NSLog(@"%@", response);
                }
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Error.\nCan't get data for statemant of fact"];
                NSLog(@"%@", response);
            }
        }
    }];
}

- (void)generateTextForEmailAndSend {
    
    [SVProgressHUD showWithStatus:@"Sending Email..."];
    NSString *saveString = [self.textView.text stringByReplacingOccurrencesOfString: @"\n" withString: @"<br>"];

        NSString *fullStatemant = [NSString stringWithFormat:@"Statemant of facts for %@:<br>==========================<br><br>%@",self.shipName,saveString];
        NSLog(@"%@",fullStatemant);
        
        [[NetworkController sharedInstance]sendEmailToUserWithText:fullStatemant fileName:@"TPT Enquiry" subject:@"Statemant of facts" WithResponseBlock:^(BOOL success, id response) {
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"Email sent."];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Error sending email. Please, try again."];
            }
        }];
}

#pragma mark - Navigation

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:kStatemantOFFactsViewControllerToMapViewViewControllerSegue]) {
//        MapViewViewController *destViewController = segue.destinationViewController;
//        destViewController.latitude = latitude;
//        destViewController.longitude = longitude;
//        destViewController.isHomeLocation = [NSNumber numberWithBool:NO];
//    }
//    if ([segue.identifier isEqualToString:kStatemantOFFactsViewControllerToPDFViewControllerSegue]) {
//        PDFViewController *destViewController = segue.destinationViewController;
//        destViewController.pdfData = reportData;
//    }
//}

#pragma mark - IBActions

- (IBAction)buttonEmailStatemant:(UIButton *)sender {
    [self generateTextForEmailAndSend];
}

@end
