//
//  PositionsSettingsViewController.h
//  TPT
//
//  Created by Bosko Barac on 12/17/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface PositionsSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintButtonSaveTop;
@property (weak, nonatomic) IBOutlet UILabel *labelCBM;
@property (weak, nonatomic) IBOutlet UILabel *labelDWT;
@property (weak, nonatomic) IBOutlet UILabel *labelLOA;
@property (weak, nonatomic) IBOutlet UILabel *labelLAST;
@property (weak, nonatomic) IBOutlet UILabel *labelOPEN;
@property (weak, nonatomic) IBOutlet UILabel *labelSTATUS;
@property (weak, nonatomic) IBOutlet UILabel *labelSIRE;
@property (weak, nonatomic) IBOutlet UILabel *labelTEMA;
@property (weak, nonatomic) IBOutlet UIButton *buttonCbm;
@property (weak, nonatomic) IBOutlet UIButton *buttonDwt;
@property (weak, nonatomic) IBOutlet UIButton *buttonLoa;
@property (weak, nonatomic) IBOutlet UIButton *buttonLast;
@property (weak, nonatomic) IBOutlet UIButton *buttonOpen;
@property (weak, nonatomic) IBOutlet UIButton *buttonStatus;
@property (weak, nonatomic) IBOutlet UIButton *buttonSire;
@property (weak, nonatomic) IBOutlet UIButton *buttonTema;
@property (weak, nonatomic) IBOutlet UIView *viewForButtonSave;


- (IBAction)buttonCbm:(UIButton *)sender;
- (IBAction)buttonDwt:(UIButton *)sender;
- (IBAction)buttonLoa:(UIButton *)sender;
- (IBAction)buttonLast:(UIButton *)sender;
- (IBAction)buttonOpen:(UIButton *)sender;
- (IBAction)buttonStatus:(UIButton *)sender;
- (IBAction)buttonSire:(UIButton *)sender;
- (IBAction)buttonTema:(UIButton *)sender;
- (IBAction)buttonSave:(UIButton *)sender;



@end
