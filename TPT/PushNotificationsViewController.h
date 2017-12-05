//
//  PushNotificationsViewController.h
//  TPT
//
//  Created by Bosko Barac on 10/21/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface PushNotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonSave:(UIButton *)sender;
@end
