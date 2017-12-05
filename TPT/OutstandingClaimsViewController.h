//
//  OutstandingClaimsViewController.h
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface OutstandingClaimsViewController : UIViewController

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *charterId;
@property (strong, nonatomic) NSString *shipName;
@property (strong, nonatomic) NSString *date;

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)buttonRequest:(UIButton *)sender;
@end
