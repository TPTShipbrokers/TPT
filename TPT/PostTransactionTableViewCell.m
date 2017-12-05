//
//  PostTransactionTableViewCell.m
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "PostTransactionTableViewCell.h"

@implementation PostTransactionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonCharterParty:(UIButton *)sender {
    [self.delegate CharterPartyPressed:self.tag];
}

- (IBAction)buttonOutstandingClaims:(UIButton *)sender {
    [self.delegate OutstandingPressed:self.tag];

}

- (IBAction)buttonInvoice:(UIButton *)sender {
    [self.delegate invoicePressed:self.tag];
}

- (IBAction)buttonStatemant:(UIButton *)sender {
    [self.delegate StatemantOfFactsPressed:self.tag];
}
@end
