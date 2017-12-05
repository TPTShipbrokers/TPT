//
//  InvoiceViewController.h
//  TPT
//
//  Created by Bosko Barac on 10/15/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface InvoiceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *invoice;
@property (strong, nonatomic) NSString *shipNameAndTime;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *status;

@property (strong, nonatomic) NSString *charterId;
@property (strong, nonatomic) NSString *shipName;
@property (strong, nonatomic) NSString *date;

@property (weak, nonatomic) IBOutlet UIButton *buttonMarkAll;

@property (weak, nonatomic) IBOutlet UIButton *buttonEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelSNo;
@property (weak, nonatomic) IBOutlet UILabel *labelRatePerDay;
@property (weak, nonatomic) IBOutlet UILabel *labelNoOfDays;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalAmount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labelNameTime;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomViewForTableView;
@property (weak, nonatomic) IBOutlet UIView *viewForTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableViewBottom;

- (IBAction)buttonEmail:(UIButton *)sender;
- (IBAction)buttonMarkAll:(UIButton *)sender;
- (IBAction)buttonDownload:(UIButton *)sender;


@end
