//
//  PositionsTableViewCell.m
//  TPT
//
//  Created by Bosko Barac on 12/7/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "PositionsTableViewCell.h"

@implementation PositionsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonCall:(UIButton *)sender {
    [self.delegate CallBrokerPressed:self.tag];

}

- (IBAction)buttonEmail:(UIButton *)sender {
    [self.delegate EmailPressed:self.tag];
}
@end
