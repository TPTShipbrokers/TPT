//
//  ShipDocumentationViewController.h
//  TPT
//
//  Created by Bosko Barac on 2/25/16.
//  Copyright © 2016 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ShipDocumentationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate >

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *charteringId;


@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomViewBehindTableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDownloadDocuemtns;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmailDocuments;
@property (weak, nonatomic) IBOutlet UIView *viewForCover;

- (IBAction)buttonDownloadDocuments:(UIButton *)sender;
- (IBAction)buttonEmailDocuments:(UIButton *)sender;
- (IBAction)buttonMarkAll:(UIButton *)sender;

@end
