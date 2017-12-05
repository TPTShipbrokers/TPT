//
//  FilterViewController.m
//  TPT
//
//  Created by Bosko Barac on 9/8/16.
//  Copyright © 2016 Borne Agency. All rights reserved.
//

#import "FilterViewController.h"
@import Firebase;

@interface FilterViewController ()

@end

@implementation FilterViewController {
    BOOL sireChecked;
    BOOL temaSuitableChecked;
    BOOL numberChecked;
    BOOL setFilter;
    BOOL cleanChecked;
    BOOL dirtyChecked;
    int numberSelectedFilter;
    NSString *sire;
    NSString *temaSuitable;
    NSString *cleanDirty;
    UIImage *radioButtonGray;
    UIImage *radioButtonBlue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"Filter"
                        parameters:nil];
}

- (void)initialSetup {
    
    if (iPhone6) {
        self.constraintTopViewForSave.constant = self.constraintTopViewForSave.constant + 68;
    }
    else if (iphone5) {
        self.constraintTopViewForSave.constant = self.constraintTopViewForSave.constant - 31;
    }
    else if (iPhone6Plus) {
        self.constraintTopViewForSave.constant = self.constraintTopViewForSave.constant +136;
    }
    
    radioButtonBlue = [UIImage imageNamed:@"RadioButtonBlue"];
    radioButtonGray = [UIImage imageNamed:@"RadioButtonGray"];

    setFilter = [[NSUserDefaults standardUserDefaults] boolForKey:@"FilterActive"];
    if (setFilter) {
        NSNumber *numberselected = [[NSUserDefaults standardUserDefaults] objectForKey:@"NumberSelectedFilter"];
        numberSelectedFilter = numberselected.intValue;
        if (numberSelectedFilter == 5) {
            [self.buttonFive setImage:radioButtonBlue forState:UIControlStateNormal];
            [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        }
        else if (numberSelectedFilter == 10) {
            [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
            [self.buttonTen setImage:radioButtonBlue forState:UIControlStateNormal];
            [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        }
        else if (numberSelectedFilter == 15) {
            [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
            [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button15 setImage:radioButtonBlue forState:UIControlStateNormal];
            [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        }
        else if (numberSelectedFilter == 20) {
            [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
            [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button20 setImage:radioButtonBlue forState:UIControlStateNormal];
            [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        }
        else if (numberSelectedFilter == 25) {
            [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
            [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button25 setImage:radioButtonBlue forState:UIControlStateNormal];
            [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        }
        else if (numberSelectedFilter == 30) {
            [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
            [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
            [self.button30 setImage:radioButtonBlue forState:UIControlStateNormal];
        }
        sire = [[NSUserDefaults standardUserDefaults] objectForKey:@"SireFilter"];
        temaSuitable = [[NSUserDefaults standardUserDefaults] objectForKey:@"TemaSuitableFilter"];
        if (![sire isEqualToString:@""]) {
            [self.buttonSIre setImage:radioButtonBlue forState:UIControlStateNormal];
        }
        if (![temaSuitable isEqualToString:@""]) {
            [self.buttonTema setImage:radioButtonBlue forState:UIControlStateNormal];
        }
        cleanDirty = [[NSUserDefaults standardUserDefaults] objectForKey:@"CleanDirtyFilter"];
        if ([cleanDirty isEqualToString:@"clean"]) {
            cleanChecked = YES;
            dirtyChecked = NO;
            [self.buttonClean setImage:radioButtonBlue forState:UIControlStateNormal];
            [self.buttonDirty setImage:radioButtonGray forState:UIControlStateNormal];
        }
        else if ([cleanDirty isEqualToString:@"dirty"]) {
            cleanChecked = NO;
            dirtyChecked = YES;
            [self.buttonClean setImage:radioButtonGray forState:UIControlStateNormal];
            [self.buttonDirty setImage:radioButtonBlue forState:UIControlStateNormal];
        }
        else {
            cleanChecked = NO;
            dirtyChecked = NO;
            [self.buttonClean setImage:radioButtonGray forState:UIControlStateNormal];
            [self.buttonDirty setImage:radioButtonGray forState:UIControlStateNormal];
        }
    }
    else {
        sireChecked = NO;
        sire = @"";
        temaSuitable = @"";
        temaSuitableChecked = NO;
        numberChecked = NO;
        setFilter = NO;
        numberSelectedFilter = 0;
        cleanDirty = @"";
        cleanChecked = NO;
        dirtyChecked = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonSire:(id)sender {
    sireChecked =! sireChecked;
    
    if (sireChecked) {
        [self.buttonSIre setImage:radioButtonBlue forState:UIControlStateNormal];
        sire = @"yes";
    }
    else {
        [self.buttonSIre setImage:radioButtonGray forState:UIControlStateNormal];
        sire = @"no";
    }
}

- (IBAction)buttonTema:(id)sender {
    temaSuitableChecked =! temaSuitableChecked;
    
    if (temaSuitableChecked) {
        [self.buttonTema setImage:radioButtonBlue forState:UIControlStateNormal];
        temaSuitable = @"yes";
    }
    else {
        [self.buttonTema setImage:radioButtonGray forState:UIControlStateNormal];
        temaSuitable = @"";
    }
}

- (IBAction)buttonClean:(id)sender {
    cleanChecked =! cleanChecked;
    if (cleanChecked) {
        dirtyChecked = NO;
        cleanDirty = @"clean";
        [self.buttonClean setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.buttonDirty setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.buttonClean setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonDirty setImage:radioButtonGray forState:UIControlStateNormal];
        cleanDirty = @"";
    }
    NSLog(@"%@", cleanDirty);

}

- (IBAction)buttonDirty:(id)sender {
    dirtyChecked =! dirtyChecked;
    if (dirtyChecked) {
        cleanChecked = NO;
        cleanDirty = @"dirty";
        [self.buttonClean setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonDirty setImage:radioButtonBlue forState:UIControlStateNormal];
    }
    else {
        [self.buttonClean setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonDirty setImage:radioButtonGray forState:UIControlStateNormal];
        cleanDirty = @"";
    }
    NSLog(@"%@", cleanDirty);
}

- (IBAction)button5:(id)sender {
    if (numberSelectedFilter == 5) {
        numberSelectedFilter = 0;
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.buttonFive setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 5;
    }
}

- (IBAction)button10:(id)sender {
    if (numberSelectedFilter == 10) {
        numberSelectedFilter = 0;
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.buttonTen setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 10;
    }
}

- (IBAction)button15:(id)sender {
    if (numberSelectedFilter == 15) {
        numberSelectedFilter = 0;
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        
        [self.button15 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 15;
    }
}

- (IBAction)button20:(id)sender {
    if (numberSelectedFilter == 20) {
        numberSelectedFilter = 0;
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button20 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 20;
    }
}

- (IBAction)button25:(id)sender {
    
    if (numberSelectedFilter == 25) {
        numberSelectedFilter = 0;
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button25 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 25;
    }
}

- (IBAction)button30:(id)sender {
    if (numberSelectedFilter == 30) {
        numberSelectedFilter = 0;
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button30 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
        [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 30;
    }
}

- (IBAction)buttonLocation:(id)sender {
    [self performSegueWithIdentifier:kFilterViewControllerToLocationsViewControllerSegue sender:self];
}

- (IBAction)buttonSave:(id)sender {
    
    if (numberSelectedFilter > 0 || temaSuitableChecked || sireChecked || cleanChecked || dirtyChecked) {
        [[NSUserDefaults standardUserDefaults] setObject:cleanDirty forKey:@"CleanDirtyFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:numberSelectedFilter] forKey:@"NumberSelectedFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:sire forKey:@"SireFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:temaSuitable forKey:@"TemaSuitableFilter"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FilterActive"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFilterActiveNotification object:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:numberSelectedFilter] forKey:@"NumberSelectedFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:sire forKey:@"SireFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:temaSuitable forKey:@"TemaSuitableFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:cleanDirty forKey:@"CleanDirtyFilter"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FilterActive"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFilterActiveNotification object:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)buttonClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonReset:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"NumberSelectedFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"SireFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"TemaSuitableFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"CleanDirtyFilter"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FilterActive"];
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"SelectedLocation"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LocationIsSelected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    sireChecked = NO;
    sire = @"";
    temaSuitable = @"";
    temaSuitableChecked = NO;
    numberChecked = NO;
    setFilter = NO;
    numberSelectedFilter = 0;
    cleanDirty = @"";
    cleanChecked = NO;
    dirtyChecked = NO;
    
    // reset buttons
    
    [self.buttonFive setImage:radioButtonGray forState:UIControlStateNormal];
    [self.buttonTen setImage:radioButtonGray forState:UIControlStateNormal];
    [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
    [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
    [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
    [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    
    [self.buttonClean setImage:radioButtonGray forState:UIControlStateNormal];
    [self.buttonDirty setImage:radioButtonGray forState:UIControlStateNormal];
    
    [self.buttonTema setImage:radioButtonGray forState:UIControlStateNormal];
    
    [self.buttonSIre setImage:radioButtonGray forState:UIControlStateNormal];
    
    [SVProgressHUD showSuccessWithStatus:@"Filters cleared."];
}
@end
