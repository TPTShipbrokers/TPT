//
//  CharteringTableViewCell.m
//  TPT
//
//  Created by Boshko Barac on 12/9/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "CharteringTableViewCell.h"

@implementation CharteringTableViewCell

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

- (IBAction)buttonDocumentation:(UIButton *)sender {
    [self.delegate DocumentationPressed:self.tag];
}

- (IBAction)buttonPlan:(UIButton *)sender {
    [self.delegate PlanPressed:self.tag];
}

- (IBAction)buttonStatemantOfFacts:(UIButton *)sender {
    [self.delegate StatemantOfFactsPressed:self.tag];
}

- (IBAction)buttonInvoice:(id)sender {
    [self.delegate InvoicePressed:self.tag];

}
@end
