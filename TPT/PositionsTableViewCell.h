//
//  PositionsTableViewCell.h
//  TPT
//
//  Created by Bosko Barac on 12/7/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PositionsListTableViewCellDelegate <NSObject>
- (void)EmailPressed:(NSInteger)tag;
- (void)CallBrokerPressed:(NSInteger)tag;

@end

@interface PositionsTableViewCell : UITableViewCell

@property (strong, nonatomic) id<PositionsListTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *labelOpenStatic;
@property (weak, nonatomic) IBOutlet UIView *viewForBorder;
@property (weak, nonatomic) IBOutlet UILabel *labelOpen;
@property (weak, nonatomic) IBOutlet UILabel *labelDateDay;
@property (weak, nonatomic) IBOutlet UILabel *labelDateMonth;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelBoatname;
@property (weak, nonatomic) IBOutlet UILabel *labelDwt;
@property (weak, nonatomic) IBOutlet UILabel *labelLoa;
@property (weak, nonatomic) IBOutlet UILabel *labelLast;
@property (weak, nonatomic) IBOutlet UILabel *labelImo;
@property (weak, nonatomic) IBOutlet UILabel *labelHull;
@property (weak, nonatomic) IBOutlet UILabel *labelOpenCellDrop;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelSire;
@property (weak, nonatomic) IBOutlet UILabel *labelIntake;
@property (weak, nonatomic) IBOutlet UILabel *labelTemaSuitable;
@property (weak, nonatomic) IBOutlet UILabel *labelCabortage;
@property (weak, nonatomic) IBOutlet UILabel *labelComments;
@property (weak, nonatomic) IBOutlet UILabel *labelLastUpdated;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDropIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelImoForHide;
@property (weak, nonatomic) IBOutlet UILabel *labelCbm;
@property (weak, nonatomic) IBOutlet UIButton *buttonBroker;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelTree;
@property (weak, nonatomic) IBOutlet UILabel *labelFour;
@property (weak, nonatomic) IBOutlet UILabel *labelDateTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelMonthTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelLocationTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelNameTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelDetailsOne;
@property (weak, nonatomic) IBOutlet UILabel *labelDetailsTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelDetailsTree;
@property (weak, nonatomic) IBOutlet UILabel *labelDetailsFour;
@property (weak, nonatomic) IBOutlet UILabel *labelOnSubs;


@property (weak, nonatomic) IBOutlet UIView *viewForPreferredPositions;



- (IBAction)buttonCall:(UIButton *)sender;
- (IBAction)buttonEmail:(UIButton *)sender;



@end
