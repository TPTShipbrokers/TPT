//
//  FilterViewController.h
//  TPT
//
//  Created by Bosko Barac on 9/8/16.
//  Copyright © 2016 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface FilterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *buttonSIre;
@property (weak, nonatomic) IBOutlet UIButton *buttonTema;
@property (weak, nonatomic) IBOutlet UIButton *buttonClean;
@property (weak, nonatomic) IBOutlet UIButton *buttonDirty;
@property (weak, nonatomic) IBOutlet UIButton *buttonFive;
@property (weak, nonatomic) IBOutlet UIButton *buttonTen;
@property (weak, nonatomic) IBOutlet UIButton *button15;
@property (weak, nonatomic) IBOutlet UIButton *button20;
@property (weak, nonatomic) IBOutlet UIButton *button25;
@property (weak, nonatomic) IBOutlet UIButton *button30;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopViewForSave;

- (IBAction)buttonSire:(id)sender;
- (IBAction)buttonTema:(id)sender;
- (IBAction)buttonClean:(id)sender;
- (IBAction)buttonDirty:(id)sender;
- (IBAction)button5:(id)sender;
- (IBAction)button10:(id)sender;
- (IBAction)button15:(id)sender;
- (IBAction)button20:(id)sender;
- (IBAction)button25:(id)sender;
- (IBAction)button30:(id)sender;
- (IBAction)buttonLocation:(id)sender;
- (IBAction)buttonSave:(id)sender;
- (IBAction)buttonClose:(id)sender;
- (IBAction)buttonReset:(UIButton *)sender;


@end
