//
//  CharteringTableViewCell.h
//  TPT
//
//  Created by Boshko Barac on 12/9/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CharteringTableViewCellDelegate <NSObject>
- (void)StatemantOfFactsPressed:(NSInteger)tag;
- (void)CharterPartyPressed:(NSInteger)tag;
- (void)DocumentationPressed:(NSInteger)tag;
- (void)PlanPressed:(NSInteger)tag;
- (void)InvoicePressed:(NSInteger)tag;


@end

@interface CharteringTableViewCell : UITableViewCell

@property (strong, nonatomic) id<CharteringTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewClock;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewShip;
@property (weak, nonatomic) IBOutlet UILabel *labelShipName;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDropDown;
@property (weak, nonatomic) IBOutlet UIButton *buttonStatemantOfFacts;
@property (weak, nonatomic) IBOutlet UILabel *labelID;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCountDownClock;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSmallClock;


- (IBAction)buttonCharterParty:(UIButton *)sender;
- (IBAction)buttonDocumentation:(UIButton *)sender;
- (IBAction)buttonPlan:(UIButton *)sender;
- (IBAction)buttonStatemantOfFacts:(UIButton *)sender;
- (IBAction)buttonInvoice:(id)sender;

@end
