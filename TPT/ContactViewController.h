//
//  ContactViewController.h
//  TPT
//
//  Created by Bosko Barac on 12/17/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CNContactViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonMenu:(UIBarButtonItem *)sender;
@end
