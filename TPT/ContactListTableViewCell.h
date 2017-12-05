//
//  ContactListTableViewCell.h
//  TPT
//
//  Created by Bosko Barac on 12/17/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPosition;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone1;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone2;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail1;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail2;
@property (weak, nonatomic) IBOutlet UIView *viewForContent;

@end
