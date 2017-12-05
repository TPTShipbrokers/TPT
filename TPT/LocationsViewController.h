//
//  LocationsViewController.h
//  TPT
//
//  Created by Bosko Barac on 9/9/16.
//  Copyright © 2016 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface LocationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buttonSave:(id)sender;

@end
