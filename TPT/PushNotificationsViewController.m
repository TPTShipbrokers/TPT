//
//  PushNotificationsViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/21/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "PushNotificationsViewController.h"
#import "PushNotificationsTableViewCell.h"
#import "NetworkController.h"
#include "AppDelegate.h"
@import Firebase;

@interface PushNotificationsViewController () 
@property (strong, nonatomic) NSMutableArray *notificationsArray;

@end

@implementation PushNotificationsViewController {
    NSNumber *livePositionUpdates;
    NSNumber *outstandingClaims;
    NSNumber *subsDue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"PushNotifications"
                        parameters:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.scrollEnabled = NO;
    [self getUserDetails];
    
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
        [self getUserDetails];
    }
}

#pragma mark - Private

- (void)getUserDetails {
    [[NetworkController sharedInstance]getUserDetailsWithResponseBlock:^(BOOL success, id response) {
        if (success) {
            //get user details after login
            
            NSDictionary *userdetails = response;
            NSDictionary *notificationSettings = [userdetails objectForKey:@"notification_settings"];
            livePositionUpdates = [notificationSettings objectForKey:@"live_position_updates"];
            outstandingClaims = [NSNumber numberWithInt:1];
            subsDue = [notificationSettings objectForKey:@"subs_due"];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"%@", response);
        }
    }];
}

#pragma mark SetupUiTableViewCell

- (void)setupCell:(PushNotificationsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [cell.labelName setText:@"SUBS DUE"];
        [cell.switchNotification setOn:subsDue.boolValue];
    }
//    else if (indexPath.row == 1) {
//        [cell.labelName setText:@"OUTSTANDING CLAIMS"];
//        [cell.switchNotification setOn:outstandingClaims.boolValue];
//    }
    else if (indexPath.row == 1){
        [cell.labelName setText:@"LIVE POSITION UPDATES"];
        [cell.switchNotification setOn:livePositionUpdates.boolValue];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PushNotificationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPushNotificationsTableViewCellIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    [self setupCell:cell atIndexPath:indexPath];
    [cell.switchNotification setTag:indexPath.row];
    [cell.switchNotification addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    return cell;
}

- (void)switchChanged:(UISwitch *)sender {
    
    BOOL value = sender.on;
    if (sender.tag == 0) {
        NSInteger i = @(value).integerValue;
        subsDue = [NSNumber numberWithInteger:i];
    }
//    else if (sender.tag == 1) {
//        NSInteger i = @(value).integerValue;
//        outstandingClaims = [NSNumber numberWithInteger:i];
//    }
    else if (sender.tag == 1) {
        NSInteger i = @(value).integerValue;
        livePositionUpdates = [NSNumber numberWithInteger:i];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 25)];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonSave:(UIButton *)sender {
    
    [SVProgressHUD showWithStatus:@"Saving changes..."];
    [[NetworkController sharedInstance] changePushNotificationsSerttingsForSubsDue:subsDue outstandingClaims:outstandingClaims livePositionUpdates:livePositionUpdates WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"Error.\nThere was an error updating notification settings."];
        }
    }];
    
}
@end
