//
//  CharteringListViewController.h
//  TPT
//
//  Created by Boshko Barac on 12/9/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <MessageUI/MessageUI.h>

@interface CharteringListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonEmail:(UIButton *)sender;
- (IBAction)buttonCall:(UIButton *)sender;
- (IBAction)buttonMenu:(UIBarButtonItem *)sender;
@end
