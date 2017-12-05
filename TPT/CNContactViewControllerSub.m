//
//  CNContactViewControllerSub.m
//  TPT
//
//  Created by Bosko Barac on 6/3/16.
//  Copyright © 2016 Borne Agency. All rights reserved.
//

#import "CNContactViewControllerSub.h"

@interface CNContactViewControllerSub ()

@end

@implementation CNContactViewControllerSub

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(setBackButton)];
    self.navigationItem.leftBarButtonItem = doneButton;
}

- (void)setBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
