//
//  TopFendersViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/13/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "TopFendersNavigationController.h"

@interface TopFendersNavigationController ()

@end

@implementation TopFendersNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   // [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return [self.visibleViewController shouldAutorotate];
}

//#pragma mark Gesture recognizer
//
//- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
//{
//    NSLog(@"????");
//    // Dismiss keyboard (optional)
//    //
//    [self.view endEditing:YES];
//    [self.frostedViewController.view endEditing:YES];
//    
//    // Present the view controller
//    //
//    [self.frostedViewController panGestureRecognized:sender];
//}

@end
