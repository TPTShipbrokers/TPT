//
//  PositionsListViewController.h
//  TPT
//
//  Created by Bosko Barac on 12/7/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PositionsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlMrHandy;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonSire;
@property (weak, nonatomic) IBOutlet UIButton *buttonTemaSuitable;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UIButton *button10;
@property (weak, nonatomic) IBOutlet UIButton *button15;
@property (weak, nonatomic) IBOutlet UIButton *button20;
@property (weak, nonatomic) IBOutlet UIButton *button25;
@property (weak, nonatomic) IBOutlet UIButton *button30;
@property (weak, nonatomic) IBOutlet UIButton *buttonFilter;

@property (weak, nonatomic) NSNumber *isWafOrAra;

- (IBAction)segmentedControlMrHandy:(UISegmentedControl *)sender;
- (IBAction)buttonSire:(UIButton *)sender;
- (IBAction)buttonTemaSuitable:(UIButton *)sender;
- (IBAction)button5:(UIButton *)sender;
- (IBAction)button10:(UIButton *)sender;
- (IBAction)button15:(UIButton *)sender;
- (IBAction)button20:(UIButton *)sender;
- (IBAction)button25:(UIButton *)sender;
- (IBAction)button30:(UIButton *)sender;
- (IBAction)buttonSave:(UIButton *)sender;
- (IBAction)buttonMenu:(UIBarButtonItem *)sender;
- (IBAction)buttonFilter:(UIButton *)sender;



@end
