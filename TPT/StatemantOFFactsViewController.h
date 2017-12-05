//
//  StatemantOFFactsViewController.h
//  TPT
//
//  Created by Bosko Barac on 10/15/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface StatemantOFFactsViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *charterId;
@property (strong, nonatomic) NSString *shipName;
@property (strong, nonatomic) NSString *date;

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

- (IBAction)buttonEmailStatemant:(UIButton *)sender;

@end
