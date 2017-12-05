//
//  PostTransactionTableViewCell.h
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostTransactionTableViewCellDelegate <NSObject>
- (void)StatemantOfFactsPressed:(NSInteger)tag;
- (void)CharterPartyPressed:(NSInteger)tag;
- (void)OutstandingPressed:(NSInteger)tag;
- (void)invoicePressed:(NSInteger)tag;
@end

@interface PostTransactionTableViewCell : UITableViewCell

@property (strong, nonatomic) id<PostTransactionTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewLock;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonStatemant;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDropDown;
@property (weak, nonatomic) IBOutlet UILabel *labelID;

- (IBAction)buttonCharterParty:(UIButton *)sender;
- (IBAction)buttonOutstandingClaims:(UIButton *)sender;
- (IBAction)buttonInvoice:(UIButton *)sender;
- (IBAction)buttonStatemant:(UIButton *)sender;



@end
