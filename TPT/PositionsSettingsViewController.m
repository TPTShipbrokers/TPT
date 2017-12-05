//
//  PositionsSettingsViewController.m
//  TPT
//
//  Created by Bosko Barac on 12/17/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "PositionsSettingsViewController.h"
#import "AppDelegate.h"
@import Firebase;

@interface PositionsSettingsViewController ()
@property (strong, nonatomic) NSMutableArray *selected;
@end

@implementation PositionsSettingsViewController {
    UIImage *radioButtonGray;
    UIImage *radioButtonBlue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initalSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"PositionSettings"
                        parameters:nil];
}

- (void)initalSetup {
    if (!iphone5 && !iPhone6 && !iPhone6Plus) {
        self.constraintButtonSaveTop.constant = self.constraintButtonSaveTop.constant + 15;
        [self.viewForButtonSave setBackgroundColor:[UIColor clearColor]];
    }
    
    radioButtonBlue = [UIImage imageNamed:@"RadioButtonBlue"];
    radioButtonGray = [UIImage imageNamed:@"RadioButtonGray"];
    
    self.selected = [[NSMutableArray alloc]init];
    BOOL userFirstEntry = [Settings isFirstEnter];
    if (!userFirstEntry) {
        [Settings setUserFirsEnteredApp:YES];
        [self.selected addObject:@"CBM"];
        [self.selected addObject:@"DWT"];
        [self.selected addObject:@"LOA"];
        [self.selected addObject:@"LAST"];
        [self.buttonCbm setSelected:YES];
        [self.buttonCbm setImage:radioButtonBlue forState:UIControlStateSelected];
        [self.buttonDwt setSelected:YES];
        [self.buttonDwt setImage:radioButtonBlue forState:UIControlStateSelected];
        [self.buttonLoa setSelected:YES];
        [self.buttonLoa setImage:radioButtonBlue forState:UIControlStateSelected];
        [self.buttonLast setSelected:YES];
        [self.buttonLast setImage:radioButtonBlue forState:UIControlStateSelected];
    }
    else {
        [self.selected addObjectsFromArray:[Settings preferredPositions]];
        
        for (NSString *position in [self.selected mutableCopy]) {
            if ([position isEqualToString:@"CBM"]) {
                [self.buttonCbm setSelected:YES];
                [self.buttonCbm setImage:radioButtonBlue forState:UIControlStateSelected];
            }
            else if ([position isEqualToString:@"DWT"]) {
                [self.buttonDwt setSelected:YES];
                [self.buttonDwt setImage:radioButtonBlue forState:UIControlStateSelected];
            }
            else if ([position isEqualToString:@"LOA"]) {
                [self.buttonLoa setSelected:YES];
                [self.buttonLoa setImage:radioButtonBlue forState:UIControlStateSelected];
            }
            else if ([position isEqualToString:@"LAST"]) {
                [self.buttonLast setSelected:YES];
                [self.buttonLast setImage:radioButtonBlue forState:UIControlStateSelected];
            }

            else if ([position isEqualToString:@"STATUS"]) {
                [self.buttonStatus setSelected:YES];
                [self.buttonStatus setImage:radioButtonBlue forState:UIControlStateSelected];
            }
            else if ([position isEqualToString:@"SIRE"]) {
                [self.buttonSire setSelected:YES];
                [self.buttonSire setImage:radioButtonBlue forState:UIControlStateSelected];
            }
            else if ([position isEqualToString:@"TEMA SUITABLE"]) {
                [self.buttonTema setSelected:YES];
                [self.buttonTema setImage:radioButtonBlue forState:UIControlStateSelected];
            }
        }
    }
    NSLog(@"%@",self.selected);
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (IBAction)buttonCbm:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self.buttonCbm setImage:radioButtonGray forState:UIControlStateNormal];
        [self.selected removeObject:@"CBM"];
    }
    else {
        if (self.selected.count >=4) {
            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
        }
        else {
            sender.selected = YES;
            [self.buttonCbm setImage:radioButtonBlue forState:UIControlStateSelected];
            [self.selected addObject:@"CBM"];
        }
    }
}

- (IBAction)buttonDwt:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self.buttonDwt setImage:radioButtonGray forState:UIControlStateNormal];
        [self.selected removeObject:@"DWT"];

    }
    else {
        if (self.selected.count >=4) {
            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
        }
        else {
            sender.selected = YES;
            [self.buttonDwt setImage:radioButtonBlue forState:UIControlStateSelected];
            [self.selected addObject:@"DWT"];
        }
    }
}

- (IBAction)buttonLoa:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self.buttonLoa setImage:radioButtonGray forState:UIControlStateNormal];
        [self.selected removeObject:@"LOA"];
    }
    else {
        if (self.selected.count >=4) {
            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
        }
        else {
            sender.selected = YES;
            [self.buttonLoa setImage:radioButtonBlue forState:UIControlStateSelected];
            [self.selected addObject:@"LOA"];
        }
    }
}

- (IBAction)buttonLast:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self.buttonLast setImage:radioButtonGray forState:UIControlStateNormal];
        [self.selected removeObject:@"LAST"];
    }
    else {
        if (self.selected.count >=4) {
            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
        }
        else {
            sender.selected = YES;
            [self.buttonLast setImage:radioButtonBlue forState:UIControlStateSelected];
            [self.selected addObject:@"LAST"];
        }
    }
}

//- (IBAction)buttonOpen:(UIButton *)sender {
//    if (sender.selected) {
//        sender.selected = NO;
//        [self.buttonOpen setImage:radioButtonGray forState:UIControlStateNormal];
//        [self.selected removeObject:@"OPEN"];
//    }
//    else {
//        if (self.selected.count >=4) {
//            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
//        }
//        else {
//            sender.selected = YES;
//            [self.buttonOpen setImage:radioButtonBlue forState:UIControlStateSelected];
//            [self.selected addObject:@"OPEN"];
//        }
//    }
//}

- (IBAction)buttonStatus:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self.buttonStatus setImage:radioButtonGray forState:UIControlStateNormal];
        [self.selected removeObject:@"STATUS"];
    }
    else {
        if (self.selected.count >=4) {
            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
        }
        else {
            sender.selected = YES;
            [self.buttonStatus setImage:radioButtonBlue forState:UIControlStateSelected];
            [self.selected addObject:@"STATUS"];
        }
    }
}

- (IBAction)buttonSire:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self.buttonSire setImage:radioButtonGray forState:UIControlStateNormal];
        [self.selected removeObject:@"SIRE"];
    }
    else {
        if (self.selected.count >=4) {
            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
        }
        else {
            sender.selected = YES;
            [self.buttonSire setImage:radioButtonBlue forState:UIControlStateSelected];
            [self.selected addObject:@"SIRE"];
        }
    }
}

- (IBAction)buttonTema:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self.buttonTema setImage:radioButtonGray forState:UIControlStateNormal];
        [self.selected removeObject:@"TEMA SUITABLE"];
    }
    else {
        if (self.selected.count >=4) {
            [SVProgressHUD showErrorWithStatus:@"Maximum number of selected positions is 4, remove some to add new."];
        }
        else {
            sender.selected = YES;
            [self.buttonTema setImage:radioButtonBlue forState:UIControlStateSelected];
            [self.selected addObject:@"TEMA SUITABLE"];
        }
    }
}

- (IBAction)buttonSave:(UIButton *)sender {
    [Settings setSelectedPostionsView:self.selected];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
