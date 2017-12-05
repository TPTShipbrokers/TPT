//
//  EmailEnquiryViewController.h
//  TPT
//
//  Created by Boshko Barac on 12/9/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface EmailEnquiryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *labelTo;
@property (weak, nonatomic) IBOutlet UILabel *labelFrom;
@property (weak, nonatomic) IBOutlet UILabel *labelSubject;
@property (weak, nonatomic) IBOutlet UILabel *labelShipName;

@property (strong, nonatomic) NSString *shipName;
@property (strong, nonatomic) NSString *dateAvailable;
@property (strong, nonatomic) NSNumber *isComingFromClaims;
@property (strong, nonatomic) NSNumber *isToUser;
@property (strong, nonatomic) NSNumber *isPostChartering;

- (IBAction)buttonEnquiry:(UIButton *)sender;

@end
