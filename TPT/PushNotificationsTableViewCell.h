//
//  PushNotificationsTableViewCell.h
//  TPT
//
//  Created by Bosko Barac on 10/21/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushNotificationsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDaily;
@property (weak, nonatomic) IBOutlet UISwitch *switchNotification;

- (IBAction)switchNotification:(UISwitch *)sender;
@end
