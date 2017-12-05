//
//  MarketReportTableViewCell.m
//  TopFenders
//
//  Created by Bosko Barac on 11/27/15.
//  Copyright © 2015 Borne. All rights reserved.
//

#import "MarketReportTableViewCell.h"

@implementation MarketReportTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.viewForContent.backgroundColor = [UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0];
    } else {
        self.viewForContent.backgroundColor = [UIColor whiteColor];
    }
}

@end
