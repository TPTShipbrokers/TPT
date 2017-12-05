//
//  TestViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/16/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "TestViewController.h"
#import "TopFendersNavigationController.h"
#import "AppDelegate.h"
#import "NetworkController.h"
#import "PositionsListViewController.h"

@interface TestViewController ()
@property (strong, nonatomic) NSMutableDictionary *userDetails;
@end

@implementation TestViewController {
    UIImage *positionImage;
    UIImage *charteringImage;
    UIImage *postCharteringImage;
    UIImage *marketReportImage;
    UIImage *settingsImage;
    UIImage *contactImage;
    UIImage *positionSelected;
    UIImage *charteringSelected;
    UIImage *marketSelected;
    UIImage *settingsSelected;
    UIImage *contactSelected;
    UIImage *postCharteringSelected;
    BOOL restricted;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialSetup {
    if (!iphone5 && !iPhone6 && !iPhone6Plus) {
        self.verticalSpaceContraintFirstView.constant = self.verticalSpaceContraintFirstView.constant - 30;
    }
    [self.labelPositions setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    [self.imageViewPosition setImage:[UIImage imageNamed:@"PositionsMenuIconSelected"]];
    
    positionImage = [UIImage imageNamed:@"PositionsMenuIcon"];
    charteringImage = [UIImage imageNamed:@"CharteringMenuIcon"];
    postCharteringImage = [UIImage imageNamed:@"PostCharteringMenuIcon"];
    marketReportImage = [UIImage imageNamed:@"MarketReportsMenuIcon"];
    settingsImage = [UIImage imageNamed:@"SettingsMenuIcon"];
    contactImage = [UIImage imageNamed:@"ContactMenuIcon"];
    positionSelected = [UIImage imageNamed:@"PositionsMenuIconSelected"];
    charteringSelected = [UIImage imageNamed:@"CharteringMenuIconSelected"];
    marketSelected = [UIImage imageNamed:@"MarketReportsMenuIconSelected"];
    settingsSelected = [UIImage imageNamed:@"SettingsMenuIconSelected"];
    contactSelected = [UIImage imageNamed:@"ContactMenuIconSelected"];
    postCharteringSelected = [UIImage imageNamed:@"PostCharteringMenuIconSelected"];
    
    UIImage *avatarTemP = [UIImage imageNamed:@"avatar"];
    [self.imageViewProfilePicture setImage:avatarTemP];

    if ([Settings isUserLoggedIn]) {
        [[NetworkController sharedInstance]getUserDetailsWithResponseBlock:^(BOOL success, id response) {
            if (success) {
                self.userDetails = [[NSMutableDictionary alloc] initWithDictionary:response];
                NSString *userName = [self.userDetails objectForKey:@"first_name"];
                NSString *userLastname = [self.userDetails objectForKey:@"last_name"];
                NSString *fullName = [NSString stringWithFormat:@"%@ %@",userName, userLastname];
                NSNumber *marketReportAccess = [self.userDetails objectForKey:@"market_report_access_level"];
                if ([marketReportAccess isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    restricted = YES;
                    [self.buttonMarketReport setEnabled:NO];
                    [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 0.5]];
                }
                else {
                    restricted = NO;
                }
                
                [self.labelUserName setText:fullName];

                NSString *imageUrl = [self.userDetails objectForKey:@"profile_picture"];
                NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",imageUrl];
                NSURL *imageURL = [NSURL URLWithString:fullUrl];

                [self.imageViewProfilePicture sd_setImageWithURL:imageURL];
            }
            else {
                NSLog(@"%@", response);
            }
        }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserLoggedIn:) name:@"UserLoggedIn" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)UserLoggedIn:(NSNotification *)notification {
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPicture"];

    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        [self.imageViewProfilePicture setImage:[UIImage imageWithData:imageData]];
    });
    
    NSString *userFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userFullName"];
    [self.labelUserName setText:userFullName];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonPositions:(UIButton *)sender {
    TopFendersNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kPositionsListNavViewController];
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    
    PositionsListViewController *positionsViewController = navigationController.viewControllers[0];
    positionsViewController.isWafOrAra = [NSNumber numberWithBool:false];
    
    [self.imageViewPosition setImage:positionSelected];
    [self.labelPositions setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    [self.imageViewChartering setImage:charteringImage];
    [self.labelChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPostChartering setImage:postCharteringImage];
    [self.labelPostChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewContact setImage:contactImage];
    [self.labelContact setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewSettings setImage:settingsImage];
    [self.labelSettings setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewMarketReport setImage:marketReportImage];
    [self.imageViewAraPositions setImage:positionImage];
    [self.labelAraPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    if (restricted) {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 0.5]];
    }
    else {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }
}

- (IBAction)buttonChartering:(UIButton *)sender {
    TopFendersNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kCharteringListNavViewController];
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    [self.imageViewChartering setImage:charteringSelected];
    [self.labelChartering setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    [self.imageViewPosition setImage:positionImage];
    [self.labelPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPostChartering setImage:postCharteringImage];
    [self.labelPostChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewContact setImage:contactImage];
    [self.labelContact setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewSettings setImage:settingsImage];
    [self.labelSettings setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewMarketReport setImage:marketReportImage];
    [self.imageViewAraPositions setImage:positionImage];
    [self.labelAraPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    if (restricted) {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 0.5]];
    }
    else {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }}

- (IBAction)buttonPostChartering:(UIButton *)sender {
    TopFendersNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kPostTransactionalNavViewController];
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    [self.imageViewPostChartering setImage:postCharteringSelected];
    [self.labelPostChartering setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    [self.imageViewChartering setImage:charteringImage];
    [self.labelChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPosition setImage:positionImage];
    [self.labelPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewSettings setImage:settingsImage];
    [self.labelSettings setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewContact setImage:contactImage];
    [self.labelContact setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewMarketReport setImage:marketReportImage];
    [self.imageViewAraPositions setImage:positionImage];
    [self.labelAraPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    if (restricted) {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 0.5]];
    }
    else {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }}

- (IBAction)buttonMarketReports:(UIButton *)sender {
    TopFendersNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kMarketReportNavViewController];
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    [self.imageViewMarketReport setImage:marketSelected];
    [self.labelMarketReport setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    [self.imageViewChartering setImage:charteringImage];
    [self.labelChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPosition setImage:positionImage];
    [self.labelPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewSettings setImage:settingsImage];
    [self.labelSettings setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewContact setImage:contactImage];
    [self.labelContact setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPostChartering setImage:postCharteringImage];
    [self.labelPostChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewAraPositions setImage:positionImage];
    [self.labelAraPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
}

- (IBAction)buttonSettings:(UIButton *)sender {
    TopFendersNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kSettingsNavViewController];
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    [self.imageViewSettings setImage:settingsSelected];
    [self.labelSettings setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    [self.imageViewChartering setImage:charteringImage];
    [self.labelChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPosition setImage:positionImage];
    [self.labelPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPostChartering setImage:postCharteringImage];
    [self.labelPostChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewContact setImage:contactImage];
    [self.labelContact setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewMarketReport setImage:marketReportImage];
    [self.imageViewAraPositions setImage:positionImage];
    [self.labelAraPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    if (restricted) {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 0.5]];
    }
    else {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }
}

- (IBAction)buttonContact:(UIButton *)sender {
    TopFendersNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kContactNavViewController];
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    
    [self.imageViewContact setImage:contactSelected];
    [self.labelContact setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    [self.imageViewSettings setImage:settingsImage];
    [self.labelSettings setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewChartering setImage:charteringImage];
    [self.labelChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPosition setImage:positionImage];
    [self.labelPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPostChartering setImage:postCharteringImage];
    [self.labelPostChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewMarketReport setImage:marketReportImage];
    [self.imageViewAraPositions setImage:positionImage];
    [self.labelAraPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    if (restricted) {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 0.5]];
    }
    else {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }
}

- (IBAction)buttonLogOut:(UIButton *)sender {
    [Settings setLoginStatus:NO];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) userLoggedOut];
}

- (IBAction)buttonAraPositions:(id)sender {
    TopFendersNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kPositionsListNavViewController];
    
    PositionsListViewController *positionsViewController = navigationController.viewControllers[0];
    positionsViewController.isWafOrAra = [NSNumber numberWithBool:true];
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    
    [self.imageViewAraPositions setImage:positionSelected];
    [self.labelAraPositions setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    [self.imageViewPosition setImage:positionImage];
    [self.labelPositions setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewChartering setImage:charteringImage];
    [self.labelChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewPostChartering setImage:postCharteringImage];
    [self.labelPostChartering setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewContact setImage:contactImage];
    [self.labelContact setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewSettings setImage:settingsImage];
    [self.labelSettings setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    [self.imageViewMarketReport setImage:marketReportImage];
    if (restricted) {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 0.5]];
    }
    else {
        [self.labelMarketReport setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }
}
@end
