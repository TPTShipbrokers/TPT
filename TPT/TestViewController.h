//
//  TestViewController.h
//  TPT
//
//  Created by Bosko Barac on 10/16/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+REFrostedViewController.h"
#import "REFrostedViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TestViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *labelLoggedIn;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;

@property (weak, nonatomic) IBOutlet UIView *viewForPositions;
@property (weak, nonatomic) IBOutlet UILabel *labelPositions;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPosition;
@property (weak, nonatomic) IBOutlet UIView *viewForChartering;
@property (weak, nonatomic) IBOutlet UILabel *labelChartering;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewChartering;
@property (weak, nonatomic) IBOutlet UIView *viewForPostChartering;
@property (weak, nonatomic) IBOutlet UILabel *labelPostChartering;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPostChartering;
@property (weak, nonatomic) IBOutlet UIView *viewForMarketReports;
@property (weak, nonatomic) IBOutlet UILabel *labelMarketReport;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMarketReport;
@property (weak, nonatomic) IBOutlet UIView *viewForSettings;
@property (weak, nonatomic) IBOutlet UILabel *labelSettings;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSettings;
@property (weak, nonatomic) IBOutlet UIView *viewForContact;
@property (weak, nonatomic) IBOutlet UILabel *labelContact;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewContact;
@property (weak, nonatomic) IBOutlet UIButton *buttonMarketReport;

@property (weak, nonatomic) IBOutlet UIView *viewForLogOut;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceContraintFirstView;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewAraPositions;
@property (weak, nonatomic) IBOutlet UILabel *labelAraPositions;
@property (weak, nonatomic) IBOutlet UIButton *buttonAraPositions;


- (IBAction)buttonPositions:(UIButton *)sender;
- (IBAction)buttonChartering:(UIButton *)sender;
- (IBAction)buttonPostChartering:(UIButton *)sender;
- (IBAction)buttonMarketReports:(UIButton *)sender;
- (IBAction)buttonSettings:(UIButton *)sender;
- (IBAction)buttonContact:(UIButton *)sender;
- (IBAction)buttonLogOut:(UIButton *)sender;
- (IBAction)buttonAraPositions:(id)sender;




@end
