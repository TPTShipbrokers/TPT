//
//  PostTransactionalViewController.h
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <MessageUI/MessageUI.h>

@interface PostTransactionalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonCall:(UIButton *)sender;
- (IBAction)buttonEmail:(UIButton *)sender;
- (IBAction)buttonMenu:(UIBarButtonItem *)sender;

@end
