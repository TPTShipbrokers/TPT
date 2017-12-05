//
//  MarketReportViewController.h
//  TopFenders
//
//  Created by Bosko Barac on 11/27/15.
//  Copyright © 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface MarketReportViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonMenu:(UIBarButtonItem *)sender;
@end
