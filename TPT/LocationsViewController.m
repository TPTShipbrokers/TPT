//
//  LocationsViewController.m
//  TPT
//
//  Created by Bosko Barac on 9/9/16.
//  Copyright © 2016 Borne Agency. All rights reserved.
//

#import "LocationsViewController.h"
#import "LocationsTableViewCell.h"
#import "NetworkController.h"
@import Firebase;

@interface LocationsViewController ()
@property (strong, nonatomic) NSMutableArray *selectedCells;
@property (strong, nonatomic) NSMutableArray *locations;
@end

@implementation LocationsViewController {
    UIImage *selectedImage;
    UIImage *notSelectedImage;
    NSString *selectedLocation;
    BOOL isAlreadySelected;
    NSIndexPath *indexpathForSelected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    [self getLocations];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"ChooseLocation"
                        parameters:nil];
}

- (void)initialSetup {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    selectedImage = [UIImage imageNamed:@"RadioButtonBlue"];
    notSelectedImage = [UIImage imageNamed:@"RadioButtonGray"];
    
    if([[NSUserDefaults standardUserDefaults] arrayForKey:@"SelectedLocation"] != nil) {
        self.selectedCells = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLocation"]];
    }
    else {
        self.selectedCells = [[NSMutableArray alloc] init];
    }
}

#pragma mark - Private

- (void)getLocations {
    [[NetworkController sharedInstance]getPositionsLocationsWithResponseBlock:^(BOOL success, id response) {
        if (success) {
            self.locations = response;
            [self.tableView reloadData];
        }
        else {
            if ([response isKindOfClass:[NSString class]]) {
                if ([response isEqualToString:@"No internet connection."]) {
                    [SVProgressHUD showErrorWithStatus:@"Error.\nNo internet connection."];
                    NSLog(@"%@", response);
                }
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Error.\nCan't get data."];
                NSLog(@"%@", response);
            }
        }
    }];

}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.locations.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLocationsTableViewCellIdentifier forIndexPath:indexPath];
    [self setupCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LocationsTableViewCell *cell = (LocationsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *locationDictionry = [self.locations objectAtIndex:indexPath.row];

    if ([self.selectedCells containsObject:[locationDictionry objectForKey:@"location"]]) {

        [self.selectedCells removeObject: [locationDictionry objectForKey:@"location"]];
        [cell.iamgeViewCheck setImage:[UIImage imageNamed:@"RadioButtonGray"]];
        [cell.labelName setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }
    else {
        [self.selectedCells addObject: [locationDictionry objectForKey:@"location"]];
        [cell.iamgeViewCheck setImage:[UIImage imageNamed:@"RadioButtonBlue"]];
        [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    }
//
//    if ([indexpathForSelected isEqual:indexPath]) {
//        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//        indexpathForSelected = nil;
//        selectedLocation = @"";
//    }
//    else {
//        indexpathForSelected = indexPath;
//        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//        [cell setSelected:YES];
//        NSDictionary *locationDictionry = [self.locations objectAtIndex:indexPath.row];
//        selectedLocation = [locationDictionry objectForKey:@"location"];
//    }
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    LocationsTableViewCell *cell = (LocationsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    if ([indexpathForSelected isEqual:indexPath]) {
//        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//        selectedLocation = @"";
//    }
//    [cell setSelected:NO];
//    selectedLocation = @"";
//}

#pragma mark SetupUiITableViewCell

- (void)setupCell:(LocationsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *locationDictionry = [self.locations objectAtIndex:indexPath.row];
    NSString *locationName = [locationDictionry objectForKey:@"location"];
    
    if ([self.selectedCells containsObject:  [locationDictionry objectForKey:@"location"]]) {

        [cell.iamgeViewCheck setImage:[UIImage imageNamed:@"RadioButtonBlue"]];
        [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    }

//    if (isAlreadySelected) {
//        if ([locationName isEqualToString:selectedLocation]) {
//            indexpathForSelected = indexPath;
//            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//            [cell setSelected:YES];
//        }
//    }
    cell.labelName.text = locationName;
}

- (IBAction)buttonSave:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedCells forKey:@"SelectedLocation"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LocationIsSelected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
