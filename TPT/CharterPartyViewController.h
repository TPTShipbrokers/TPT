//
//  CharterPartyViewController.h
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface CharterPartyViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) NSString *charterId;
@property (strong, nonatomic) NSString *shipName;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *status;

@property (weak, nonatomic) IBOutlet UILabel *labelShipName;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)buttonEmail:(UIButton *)sender;

@end
