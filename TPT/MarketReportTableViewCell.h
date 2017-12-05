//
//  MarketReportTableViewCell.h
//  TopFenders
//
//  Created by Bosko Barac on 11/27/15.
//  Copyright © 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarketReportTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewForContent;
@property (weak, nonatomic) IBOutlet UILabel *labelNewsLetterName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@end
