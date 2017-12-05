//
//  RootViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "RootViewController.h"
#import "NetworkController.h"
#import "TestViewController.h"

@interface RootViewController ()
@end

@implementation RootViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.liveBlur = YES;
    self.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleDark;
    self.blurTintColor = [UIColor colorWithRed: 0/255.0 green: 0/255.0 blue: 0/255.0 alpha: 0.6];
    self.blurRadius = 0.0f;
    self.backgroundFadeAmount = 0.6;
    self.limitMenuViewSize = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kPositionsListNavViewController];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TestViewController"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
