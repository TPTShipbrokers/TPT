//
//  InvoiceTableViewCell.m
//  TPT
//
//  Created by Bosko Barac on 10/20/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "InvoiceTableViewCell.h"

@implementation InvoiceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    if (selected) {
//        self.contentView.backgroundColor = [UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0];
//    }
//    else {
//        if(self.tag % 2 == 0){
//            self.contentView.backgroundColor = [UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 0.30];
//        }else{
//            self.contentView.backgroundColor = [ UIColor whiteColor];
//        }
//    }

    // Configure the view for the selected state
}
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
//    [super setHighlighted:highlighted animated:animated];
//    if (highlighted) {
//        self.contentView.backgroundColor = [UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0];
//    } else {
//        self.contentView.backgroundColor = [UIColor whiteColor];
//    }
//}

@end
