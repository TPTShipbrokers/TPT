//
//  PositionsListViewController.m
//  TPT
//
//  Created by Bosko Barac on 12/7/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "PositionsListViewController.h"
#import "PositionsTableViewCell.h"
#import "NetworkController.h"
#import "EmailEnquiryViewController.h"
#import "AppDelegate.h"
@import Firebase;

@interface PositionsListViewController () <PositionsListTableViewCellDelegate>
@property (strong, nonatomic) NSMutableArray *selectedCells;
@property (strong, nonatomic) NSMutableArray *selectedLocations;
@property (strong, nonatomic) NSMutableArray *positions;
@property (strong , nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UINavigationController *filterNavController;
@end

@implementation PositionsListViewController {
    UIImage *dropDownIconUpBlue;
    UIImage *dropDownIconDownBlue;
    UIImage *radioButtonGray;
    UIImage *radioButtonBlue;
    BOOL filterShowed;
    BOOL sireChecked;
    BOOL temaSuitableChecked;
    BOOL numberChecked;
    BOOL setFilter;
    int numberSelectedFilter;
    NSString *sire;
    NSString *temaSuitable;
    NSString *size;
    NSString *nameOfShip;
    NSString *dateAvailable;
    NSMutableArray *preferredPositions;
    BOOL shoudFireAlert;
    BOOL locationSelected;
    NSString *locationName;
    NSString *cleanDirty;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    [self setUpRefreshControl];
    [self refreshPositions];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isWafOrAra == [NSNumber numberWithBool:true]) {
        [FIRAnalytics logEventWithName:@"AraPositions"
                            parameters:nil];
    }
    else {
        [FIRAnalytics logEventWithName:@"WafPositions"
                            parameters:nil];
    }
}

- (void)initialSetup {
    
    if (self.isWafOrAra == [NSNumber numberWithBool:true]) {
        self.title = @"UKC POSITIONS";
        [self.segmentedControlMrHandy setTitle:@"HDY" forSegmentAtIndex:0];
    }
    else {
        self.title = @"WAF POSITIONS";
        [self.segmentedControlMrHandy setTitle:@"SMALL" forSegmentAtIndex:0];
    }
    
    self.selectedLocations = [[NSMutableArray alloc] init];
    
    sireChecked = NO;
    size = @"handy";
    temaSuitableChecked = NO;
    numberChecked = NO;
    NSNumber *numberselected = [[NSUserDefaults standardUserDefaults] objectForKey:@"NumberSelectedFilter"];
    numberSelectedFilter = numberselected.intValue;
    sire = [[NSUserDefaults standardUserDefaults] objectForKey:@"SireFilter"];
    temaSuitable = [[NSUserDefaults standardUserDefaults] objectForKey:@"TemaSuitableFilter"];
    setFilter = [[NSUserDefaults standardUserDefaults] boolForKey:@"FilterActive"];
    locationName = @"";
    cleanDirty = [[NSUserDefaults standardUserDefaults] objectForKey:@"CleanDirtyFilter"];
    if (setFilter) {
        [self.buttonFilter setTitle:@"FILTERS ON" forState:UIControlStateNormal];
        [self.buttonFilter  setBackgroundColor:[UIColor colorWithRed:3/255.0 green:196/255.0 blue:84/255.0 alpha:1.0]];
    }
    
    filterShowed = NO;
    shoudFireAlert = NO;
    
    numberSelectedFilter = 0;

    self.selectedCells = [[NSMutableArray alloc]init];
    preferredPositions = [[NSMutableArray alloc] initWithArray:[Settings preferredPositions]];
    if (!preferredPositions || preferredPositions.count == 0) {
        preferredPositions = [[NSMutableArray alloc]init];
        [preferredPositions addObject:@"CBM"];
        [preferredPositions addObject:@"DWT"];
        [preferredPositions addObject:@"LOA"];
        [preferredPositions addObject:@"LAST"];
    }
    self.positions = [[NSMutableArray alloc]init];
    self.tableView.allowsMultipleSelection = YES;
    
    dropDownIconDownBlue = [UIImage imageNamed:@"BlueDropDownIcon"];
    dropDownIconUpBlue = [UIImage imageNamed:@"BlueDropDownIconUp"];
    radioButtonBlue = [UIImage imageNamed:@"RadioButtonBlue"];
    radioButtonGray = [UIImage imageNamed:@"RadioButtonGray"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filterActive:)
                                                 name:kFilterActiveNotification
                                               object:nil];
}

- (void)restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotificationDelegate

- (void)refreshPages:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        [self refreshPositions];
    }
}

- (void)filterActive:(NSNotification *)notification {
    
    NSNumber *numberselected = [[NSUserDefaults standardUserDefaults] objectForKey:@"NumberSelectedFilter"];
    numberSelectedFilter = numberselected.intValue;
    sire = [[NSUserDefaults standardUserDefaults] objectForKey:@"SireFilter"];
    temaSuitable = [[NSUserDefaults standardUserDefaults] objectForKey:@"TemaSuitableFilter"];
    setFilter = [[NSUserDefaults standardUserDefaults] boolForKey:@"FilterActive"];
    //locationName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLocation"];
    cleanDirty = [[NSUserDefaults standardUserDefaults] objectForKey:@"CleanDirtyFilter"];
    
    if([[NSUserDefaults standardUserDefaults] arrayForKey:@"SelectedLocation"] != nil) {
        self.selectedLocations = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLocation"]];
    }

    
    if (self.selectedLocations.count > 0) {
        setFilter = YES;
    }
    if (![cleanDirty isEqualToString:@""]) {
        setFilter = YES;
    }
    
    if (setFilter) {
        [self.buttonFilter setTitle:@"FILTERS ON" forState:UIControlStateNormal];
        [self.buttonFilter  setBackgroundColor:[UIColor colorWithRed:3/255.0 green:196/255.0 blue:84/255.0 alpha:1.0]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FilterActive"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [self.buttonFilter setTitle:@"FILTER" forState:UIControlStateNormal];
        [self.buttonFilter setBackgroundColor:[UIColor colorWithRed:2/255.0 green:83/255.0 blue:156/255.0 alpha:1.0]];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FilterActive"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self refreshPositions];
}

#pragma mark - Refresh Control

-(void)setUpRefreshControl{
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView addSubview:refresh];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    [self refreshPositions];
}

- (void)refreshPositions {
    //Load Newsletters
    [SVProgressHUD showWithStatus:@"Loading positions..."];
    
    if (setFilter) {
        

        [[NetworkController sharedInstance] getLivePositionsWithFilters:size age:[NSNumber numberWithInt:numberSelectedFilter] sire:sire temaSuitable:temaSuitable locations:self.selectedLocations condition:cleanDirty isAra:self.isWafOrAra WithResponseBlock:^(BOOL success, id response) {
            if (success) {
                [SVProgressHUD dismiss];
                self.positions = [[NSMutableArray alloc] initWithArray:response];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
            }
            else {
                if ([response isKindOfClass:[NSString class]]) {
                    if ([response isEqualToString:@"No internet connection."]) {
                        [SVProgressHUD showErrorWithStatus:@"Error.\nNo internet connection."];
                        [self.refreshControl endRefreshing];
                        [self.tableView reloadData];
                        NSLog(@"%@", response);
                    }
                }
                else {
                    [SVProgressHUD showErrorWithStatus:@"No results matched Your query."];
                    [self.refreshControl endRefreshing];
                    self.positions = nil;
                    [self.tableView reloadData];
                    NSLog(@"%@", response);
                }
            }
        }];
    }
     else {

        [[NetworkController sharedInstance] getLivePositionsWithFilters:size age:[NSNumber numberWithInt:0] sire:@"" temaSuitable:@"" locations:self.selectedLocations condition:cleanDirty isAra:self.isWafOrAra WithResponseBlock:^(BOOL success, id response) {
            if (success) {
                [SVProgressHUD dismiss];
                self.positions = [[NSMutableArray alloc] initWithArray:response];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
            }
            else {
                if ([response isKindOfClass:[NSString class]]) {
                    if ([response isEqualToString:@"No internet connection."]) {
                        [SVProgressHUD showErrorWithStatus:@"Error.\nNo internet connection."];
                        [self.refreshControl endRefreshing];
                        [self.tableView reloadData];
                        NSLog(@"%@", response);
                    }
                }
                else {
                    [SVProgressHUD showErrorWithStatus:@"No results matched Your query."];
                    [self.refreshControl endRefreshing];
                    self.positions = nil;
                    [self.tableView reloadData];
                    NSLog(@"%@", response);
                }
            }
        }];
    }
}

#pragma mark - PositionsTableViewCellDelegate

- (void)EmailPressed:(NSInteger)tag {
    PositionsTableViewCell *cell = (PositionsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    nameOfShip = cell.labelBoatname.text;
    dateAvailable = cell.labelLastUpdated.text;

    [self performSegueWithIdentifier:kPositionsListViewControllerToEmailEnquiryViewControllerSegue sender:self];
}

- (void)CallBrokerPressed:(NSInteger)tag {
    
    // Initialize phone number to call

    NSString *phoneNumber = @"+442037448041";

    // Open URL
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Your device can't make a call."];
    }
}

#pragma mark - SetupUItableViewCell

- (void)setupTableViewCell:(PositionsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTag:indexPath.row];
    [cell.labelOnSubs setAlpha:0.0f];

    NSDictionary *position = [self.positions objectAtIndex:indexPath.row];
    NSString *name = [position objectForKey:@"name"];
    NSNumber *built = [position objectForKey:@"built"];
    [cell.labelBoatname setText:[NSString stringWithFormat:@"%@ (%@)",name, built].uppercaseString];
    NSString *status = [position objectForKey:@"status"];
    [cell.labelStatus setText:status.uppercaseString];
    
    NSString *location = [position objectForKey:@"location"];
    [cell.labelLocation setText:location.uppercaseString];
    [cell.labelLocationTwo setText:location.uppercaseString];
    if ([status isEqualToString:@"on_subs"]) {
        [cell.labelOnSubs setText:@"ON SUBS"];
        [cell.labelLocation setTextColor:[UIColor colorWithRed: 227/255.0 green: 56/255.0 blue: 41/255.0 alpha: 1.0]];
        [cell.labelLocationTwo setTextColor:[UIColor colorWithRed: 227/255.0 green: 56/255.0 blue: 41/255.0 alpha: 1.0]];
    }
    else {
        [cell.labelOnSubs setText:@""];
        [cell.labelLocation setTextColor:[UIColor colorWithRed: 83/255.0 green: 83/255.0 blue: 83/255.0 alpha: 1.0]];
        [cell.labelLocationTwo setTextColor:[UIColor colorWithRed: 83/255.0 green: 83/255.0 blue: 83/255.0 alpha: 1.0]];
    }
    
    //get the Date and format it
    NSString *openDate = [position objectForKey:@"open_date"];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [timeFormat setLocale:twentyFour];
    
    NSDate *dateFromString = [timeFormat dateFromString:openDate];
    [timeFormat setDateFormat:@"MMMM"];
    NSString *month = [timeFormat stringFromDate:dateFromString];
    [timeFormat setDateFormat:@"dd"];
    NSString *day = [timeFormat stringFromDate:dateFromString];
    [timeFormat setDateStyle:NSDateFormatterLongStyle];
    [timeFormat setTimeStyle:NSDateFormatterNoStyle];
    NSString *theTime = [timeFormat stringFromDate:dateFromString];
    [timeFormat setDateFormat:@"dd/MM/YYYY"];
    NSString *theTimeOpen = [timeFormat stringFromDate:dateFromString];


    [cell.labelDateDay setText:day];
    [cell.labelDateMonth setText:month.uppercaseString];
    [cell.labelOpenCellDrop setText:theTimeOpen.uppercaseString];
    
    [cell.labelDateTwo setText:day];
    [cell.labelMonthTwo setText:month.uppercaseString];
    [cell.labelNameTwo setText:[NSString stringWithFormat:@"%@ (%@)",name, built].uppercaseString];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    for (int i=0; i<preferredPositions.count; i++) {
        NSString *preferred = [preferredPositions objectAtIndex:i];
        if (i == 0) {
            [cell.labelOne setText:preferred];
            if ([preferred isEqualToString:@"STATUS"]) {
                [cell.labelDetailsOne setText:status.uppercaseString];
            }
            else if ([preferred isEqualToString:@"OPEN"]) {
                [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",theTime]];
            }
        }
        if (i == 1) {
            [cell.labelTwo setText:preferred];
            if ([preferred isEqualToString:@"STATUS"]) {
                [cell.labelDetailsTwo setText:status.uppercaseString];
            }
            else if ([preferred isEqualToString:@"OPEN"]) {
                [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",theTime]];
            }
        }
        if (i == 2) {
            [cell.labelTree setText:preferred];
            if ([preferred isEqualToString:@"STATUS"]) {
                [cell.labelDetailsTree setText:status.uppercaseString];
            }
            else if ([preferred isEqualToString:@"OPEN"]) {
                [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",theTime]];
            }
        }
        if (i == 3) {
            [cell.labelFour setText: preferred];
            if ([preferred isEqualToString:@"STATUS"]) {
                [cell.labelDetailsFour setText:status.uppercaseString];
            }
            else if ([preferred isEqualToString:@"OPEN"]) {
                [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",theTime]];
            }
        }
    }

    NSNumber *cbm = [position objectForKey:@"cbm"];
    if (![cbm isKindOfClass:[NSNull class]]) {
        NSString *formatted = [formatter stringFromNumber:cbm];
        [cell.labelCbm setText:[NSString stringWithFormat:@"%@", formatted]];
        if ([cell.labelOne.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",formatted]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",formatted]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",formatted]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",formatted]];
        }
    }
    else {
        [cell.labelCbm setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"CBM"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSNumber *dwt = [position objectForKey:@"dwt"];
    if (![dwt isKindOfClass:[NSNull class]]) {
        NSString *formatted = [formatter stringFromNumber:dwt];
        [cell.labelDwt setText:[NSString stringWithFormat:@"%@",formatted]];
        if ([cell.labelOne.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",formatted]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",formatted]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",formatted]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",formatted]];
        }
    }
    else {
        [cell.labelDwt setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"DWT"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSNumber *loa = [position objectForKey:@"loa"];
    if (![loa isKindOfClass:[NSNull class]]) {
        
        NSString * stringToPresent = [NSString stringWithFormat:@"%.1f", loa.doubleValue];
        [cell.labelLoa setText:[NSString stringWithFormat:@"%@ M", stringToPresent]];
        
        if ([cell.labelOne.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@ M",stringToPresent]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@ M",stringToPresent]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@ M",stringToPresent]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@ M",stringToPresent]];
        }
    }
    else {
        [cell.labelLoa setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"LOA"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSString *last = [position objectForKey:@"last"];
    if (![last isKindOfClass:[NSNull class]] && ![last isEqualToString:@""]) {
        [cell.labelLast setText:last];
        if ([cell.labelOne.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",last.uppercaseString]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",last.uppercaseString]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",last.uppercaseString]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",last.uppercaseString]];
        }
    }
    else {
        [cell.labelLast setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"LAST"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSNumber *imo = [position objectForKey:@"imo"];
    if (![imo isKindOfClass:[NSNull class]]) {
        [cell.labelImo setText:[NSString stringWithFormat:@"%@",imo]];
        if ([cell.labelOne.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",imo]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",imo]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",imo]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",imo]];
        }
    }
    else {
        [cell.labelImo setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"IMO"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSString *hull = [position objectForKey:@"hull"];
    if (![hull isKindOfClass:[NSNull class]] && ![hull isEqualToString:@""]) {
        [cell.labelHull setText:hull];
        if ([cell.labelOne.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",hull]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",hull]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",hull]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",hull]];
        }
    }
    else {
        [cell.labelHull setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"HULL"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSString *sireX = [position objectForKey:@"sire"];
    if (![sireX isKindOfClass:[NSNull class]]) {
        [cell.labelSire setText:sireX.uppercaseString];
        if ([cell.labelOne.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",sireX.uppercaseString]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",sireX.uppercaseString]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",sireX.uppercaseString]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",sireX.uppercaseString]];
        }
    }
    else {
        [cell.labelSire setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"SIRE"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSNumber *intake = [position objectForKey:@"intake"];
    if (![intake isKindOfClass:[NSNull class]]) {
        [cell.labelIntake setText:[NSString stringWithFormat:@"%@",intake]];
        if ([cell.labelOne.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",intake]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",intake]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",intake]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",intake]];
        }
    }
    else {
        [cell.labelIntake setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"INTAKE 6.4"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSString *temaS = [position objectForKey:@"tema_suitable"];
    if (![temaS isKindOfClass:[NSNull class]]) {
        [cell.labelTemaSuitable setText:temaS];
        if ([cell.labelOne.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",temaS]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",temaS]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",temaS]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",temaS]];
        }
    }
    else {
        [cell.labelTemaSuitable setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"TEMA SUITABLE"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    NSString *comments = [position objectForKey:@"comments"];
    if (![comments isKindOfClass:[NSNull class]]) {
        [cell.labelComments setText:comments.uppercaseString];
    }
    else {
        [cell.labelComments setText:@"N/A"];
    }
    
    NSString *cabotage = [position objectForKey:@"cabotage"];
    if (![cabotage isKindOfClass:[NSNull class]]) {
        [cell.labelCabortage setText:cabotage];
        if ([cell.labelOne.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsOne setText:[NSString stringWithFormat:@"%@",temaS]];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsTwo setText:[NSString stringWithFormat:@"%@",temaS]];
        }
        else  if ([cell.labelTree.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsTree setText:[NSString stringWithFormat:@"%@",temaS]];
        }
        else  if ([cell.labelFour.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsFour setText:[NSString stringWithFormat:@"%@",temaS]];
        }
    }
    else {
        [cell.labelTemaSuitable setText:@"N/A"];
        if ([cell.labelOne.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsOne setText:@"N/A"];
        }
        else  if ([cell.labelTwo.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsTwo setText:@"N/A"];
        }
        else  if ([cell.labelTree.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsTree setText:@"N/A"];
        }
        else  if ([cell.labelFour.text isEqualToString:@"CABOTAGE"]) {
            [cell.labelDetailsFour setText:@"N/A"];
        }
    }
    
    NSString *lastUpdateDate = [position objectForKey:@"last_update"];
    [timeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [timeFormat setLocale:twentyFour];
    NSDate *dateFromStringX = [timeFormat dateFromString:lastUpdateDate];
    [timeFormat setDateFormat:@"dd/MM/yy"];
    NSString *theTimeX = [timeFormat stringFromDate:dateFromStringX];
    [cell.labelLastUpdated setText:theTimeX];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.positions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCells.count > 0) {
        for (NSNumber *selection in [self.selectedCells mutableCopy]) {
            if ([indexPath row] == [selection integerValue]) {
                return 240;
            }
        }
    }
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PositionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPositionsTableViewCellIdentifier forIndexPath:indexPath];
    [self setupTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int selection = (float)indexPath.row;
    [self.selectedCells addObject:[NSNumber numberWithInt:selection]];
    
    PositionsTableViewCell *cell = (PositionsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewDropIcon setImage:dropDownIconUpBlue];
   
    // animate
    [tableView beginUpdates];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2
                     animations:^{
                         [cell.labelSire setAlpha:1.0f];
                         [cell.labelOpenStatic setAlpha:1.0f];
                         [cell.viewForPreferredPositions setAlpha:0.0f];
                         [cell.labelOnSubs setAlpha:1.0f];

                         [self.view layoutIfNeeded];
                     }];
    [tableView endUpdates];
    [cell setSelected:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    int selection = (float)indexPath.row;
    for (NSNumber *selected in [self.selectedCells mutableCopy]) {
        if ([selected integerValue] == selection) {
            [self.selectedCells removeObject:selected];
        }
    }
    PositionsTableViewCell *cell = (PositionsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewDropIcon setImage:dropDownIconDownBlue];

    // animate
    [tableView beginUpdates];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [cell.labelSire setAlpha:0.0f];
                         [cell.labelOpenStatic setAlpha:0.0f];
                         [cell.viewForPreferredPositions setAlpha:1.0f];
                         [cell.labelOnSubs setAlpha:0.0f];

                         [self.view layoutIfNeeded];
                     }];
    [tableView endUpdates];
    [cell setSelected:NO];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [((PositionsTableViewCell *)cell) setDelegate:self];
    if (self.selectedCells.count > 0) {
        for (NSNumber *selection in [self.selectedCells mutableCopy]) {
            if ([indexPath row] == [selection integerValue]) {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[selection integerValue] inSection:0]
                                         animated:NO
                                   scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    if (((PositionsTableViewCell *)cell).selected) {
        [((PositionsTableViewCell *)cell).labelSire setAlpha:1.0f];
        [((PositionsTableViewCell *)cell).labelOpenStatic setAlpha:1.0f];
        [((PositionsTableViewCell *)cell).viewForPreferredPositions setAlpha:0.0f];
    }
    else {
        [((PositionsTableViewCell *)cell).labelSire setAlpha:0.0f];
        [((PositionsTableViewCell *)cell).labelOpenStatic setAlpha:0.0f];
        [((PositionsTableViewCell *)cell).viewForPreferredPositions setAlpha:1.0f];
    }
}


 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:kPositionsListViewControllerToEmailEnquiryViewControllerSegue]) {
         EmailEnquiryViewController *destViewController = segue.destinationViewController;
         destViewController.shipName = nameOfShip;
         destViewController.dateAvailable = dateAvailable;
         destViewController.isComingFromClaims = [NSNumber numberWithBool:NO];
     }
 }
 

#pragma mark - UISEgmentedControlDelegate

- (void) updateSegmentColors {
    UIColor *selectedColor = [UIColor colorWithRed: 2/255.0 green:83/255.0 blue:156/255.0 alpha:1.0];
    NSArray *segmentColors = [[NSArray alloc] initWithObjects:selectedColor,[UIColor clearColor], nil];
    
    UISegmentedControl *betterSegmentedControl = self.segmentedControlMrHandy;
    
    // Get number of segments
    NSUInteger numSegments = [betterSegmentedControl.subviews count];
    
    // Reset segment's color (non selected color)
    for( int i = 0; i < numSegments; i++ ) {
        // reset color
        [[betterSegmentedControl.subviews objectAtIndex:i] setTintColor:nil];
        [[betterSegmentedControl.subviews objectAtIndex:i] setTintColor:[UIColor blueColor]];
    }
    
    // Sort segments from left to right
    NSArray *sortedViews = [betterSegmentedControl.subviews sortedArrayUsingFunction:compareViewsByOrigin context:NULL];
    
    // Change color of selected segment
    NSInteger selectedIdx = betterSegmentedControl.selectedSegmentIndex;
    [[sortedViews objectAtIndex:selectedIdx] setTintColor:[segmentColors objectAtIndex:selectedIdx]];
    
    // Remove all original segments from the control
    for (id view in betterSegmentedControl.subviews) {
        [view removeFromSuperview];
    }
    
    // Append sorted and colored segments to the control
    for (id view in sortedViews) {
        [betterSegmentedControl addSubview:view];
    }
}

NSInteger static compareViewsByOrigin(id sp1, id sp2, void *context) {
    
    // UISegmentedControl segments use UISegment objects (private API). But we can safely cast them to UIView objects.
    float v1 = ((UIView *)sp1).frame.origin.x;
    float v2 = ((UIView *)sp2).frame.origin.x;
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

#pragma mark - IBActions

- (IBAction)segmentedControlMrHandy:(UISegmentedControl *)sender {
    switch (self.segmentedControlMrHandy.selectedSegmentIndex) {

        case 0:
            size = @"handy";
            [self.selectedCells removeAllObjects];
            for (PositionsTableViewCell *cell in [self.tableView visibleCells]) {
                [cell.imageViewDropIcon setImage:dropDownIconDownBlue];
            }
            [self refreshPositions];
            NSLog(@"%@",sire);
            break;
        case 1:
            size = @"mr";
            [self.selectedCells removeAllObjects];
            for (PositionsTableViewCell *cell in [self.tableView visibleCells]) {
                [cell.imageViewDropIcon setImage:dropDownIconDownBlue];
            }
            [self refreshPositions];
            NSLog(@"%@",sire);
            break;
        case 2:
            size = @"lr";
            [self.selectedCells removeAllObjects];
            for (PositionsTableViewCell *cell in [self.tableView visibleCells]) {
                [cell.imageViewDropIcon setImage:dropDownIconDownBlue];
            }
            [self refreshPositions];
            NSLog(@"%@",sire);
            break;
        default:
            break;
    }
}

- (IBAction)buttonSire:(UIButton *)sender {
    sireChecked =! sireChecked;

    if (sireChecked) {
        [self.buttonSire setImage:radioButtonBlue forState:UIControlStateNormal];
        sire = @"yes";
    }
    else {
        [self.buttonSire setImage:radioButtonGray forState:UIControlStateNormal];
        sire = @"no";
    }
}

- (IBAction)buttonTemaSuitable:(UIButton *)sender {
    temaSuitableChecked =! temaSuitableChecked;

    if (temaSuitableChecked) {
        [self.buttonTemaSuitable setImage:radioButtonBlue forState:UIControlStateNormal];
        temaSuitable = @"yes";
    }
    else {
        [self.buttonTemaSuitable setImage:radioButtonGray forState:UIControlStateNormal];
        temaSuitable = @"";
    }
}

- (IBAction)button5:(UIButton *)sender {
    
    if (numberSelectedFilter == 5) {
        numberSelectedFilter = 0;
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button5 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 5;
    }
}

- (IBAction)button10:(UIButton *)sender {
    
    if (numberSelectedFilter == 10) {
        numberSelectedFilter = 0;
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button10 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 10;
    }
}

- (IBAction)button15:(UIButton *)sender {
    
    if (numberSelectedFilter == 15) {
        numberSelectedFilter = 0;
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        
        [self.button15 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 15;
    }
}

- (IBAction)button20:(UIButton *)sender {
    
    if (numberSelectedFilter == 20) {
        numberSelectedFilter = 0;
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button20 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 20;
    }
}

- (IBAction)button25:(UIButton *)sender {
    
    if (numberSelectedFilter == 25) {
        numberSelectedFilter = 0;
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button25 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 25;
    }
}

- (IBAction)button30:(UIButton *)sender {
    
    if (numberSelectedFilter == 30) {
        numberSelectedFilter = 0;
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button30 setImage:radioButtonGray forState:UIControlStateNormal];
    }
    else {
        [self.button30 setImage:radioButtonBlue forState:UIControlStateNormal];
        [self.button5 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button10 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button15 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button20 setImage:radioButtonGray forState:UIControlStateNormal];
        [self.button25 setImage:radioButtonGray forState:UIControlStateNormal];
        numberSelectedFilter = 30;
    }
}

- (IBAction)buttonSave:(UIButton *)sender {
    if (numberSelectedFilter > 0 || sireChecked || temaSuitableChecked) {
        setFilter = YES;
        [self.buttonFilter sendActionsForControlEvents: UIControlEventTouchUpInside];
        [self refreshPositions];
    }
    else {
        setFilter = NO;
        [self.buttonFilter sendActionsForControlEvents: UIControlEventTouchUpInside];
        [self refreshPositions];
    }
}

- (IBAction)buttonMenu:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController resizeMenuViewControllerToSize:(CGSize)self.view.frame.size];
    
    // Present the view controller
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)buttonFilter:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kMainStoryboard bundle:nil];
    self.filterNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kFilterNavViewController];
    [self presentViewController: self.filterNavController animated:YES completion:nil];
}
@end
