//
//  PostTransactionalViewController.m
//  TPT
//
//  Created by Bosko Barac on 12/10/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "PostTransactionalViewController.h"
#import "PostTransactionTableViewCell.h"
#import "CharterPartyViewController.h"
#import "StatemantOFFactsViewController.h"
#import "NetworkController.h"
#import "InvoiceViewController.h"
#import "OutstandingClaimsViewController.h"
#import "AppDelegate.h"
#import "EmailEnquiryViewController.h"
@import Firebase;

@interface PostTransactionalViewController () <PostTransactionTableViewCellDelegate>
@property (strong, nonatomic) NSMutableArray *selectedCells;
@property (strong, nonatomic) NSMutableArray *postTransactions;
@property (strong , nonatomic) UIRefreshControl *refreshControl;
@end

@implementation PostTransactionalViewController {
    UIImage *dropDownIconUpBlue;
    UIImage *dropDownIconDownBlue;
    NSString *charterId;
    NSString *nameOfShip;
    NSString *currentStatus;
    NSString *currentDate;
    NSString *nameAndTime;
    NSString *statusDescription;
    NSString *phoneNumberToCall;
    UIImage *lockIcon;
    UIImage *unlockIcon;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    [self setUpRefreshControl];
    [self refreshCharteringList];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"PostChartering"
                        parameters:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    self.selectedCells = [[NSMutableArray alloc]init];
    self.tableView.allowsMultipleSelection = YES;
    self.postTransactions = [[NSMutableArray alloc]init];
    
    dropDownIconDownBlue = [UIImage imageNamed:@"BlueDropDownIcon"];
    dropDownIconUpBlue = [UIImage imageNamed:@"BlueDropDownIconUp"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];
    
    lockIcon = [UIImage imageNamed:@"LockedIcon"];
    unlockIcon = [UIImage imageNamed:@"UnlockedIcon"];
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

#pragma mark - NSNotificationDelegate

- (void)refreshPages:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        [self refreshCharteringList];
    }
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
    [self refreshCharteringList];
}

- (void)refreshCharteringList {
    //Load Newsletters
    [SVProgressHUD showWithStatus:@"Loading chartering list..."];
    
    [[NetworkController sharedInstance] getPostCharteringListWithResponseBlock:^(BOOL success, id response) {
        if (success) {
            [SVProgressHUD dismiss];
            self.postTransactions = response;
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
            NSLog(@"%@", self.postTransactions);
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
                [SVProgressHUD showErrorWithStatus:@"There is no results for post chartering."];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                NSLog(@"%@", response);
            }
        }
    }];
}

#pragma mark - PostTransactionTableViewCellDelegate

- (void)StatemantOfFactsPressed:(NSInteger)tag {
    PostTransactionTableViewCell *cell = (PostTransactionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    NSDictionary *transaction = [self.postTransactions objectAtIndex:tag];
    
    charterId = [transaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    [self performSegueWithIdentifier:kPostTransactionalViewControllerToStatemantOFFactsViewControllerSegue sender:self];
}

- (void)CharterPartyPressed:(NSInteger)tag {
    PostTransactionTableViewCell *cell = (PostTransactionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    NSDictionary *transaction = [self.postTransactions objectAtIndex:tag];
    
    charterId = [transaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    
    [self performSegueWithIdentifier:kPostTransactionalViewControllerToCharterPartyViewControllerSegue sender:self];
}

- (void)OutstandingPressed:(NSInteger)tag {
    PostTransactionTableViewCell *cell = (PostTransactionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];

    NSDictionary *transaction = [self.postTransactions objectAtIndex:tag];
    
    charterId = [transaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    
    [self performSegueWithIdentifier:kPostTransactionalViewControllerToOutstandingClaimsViewControllerSegue sender:self];
}

- (void)invoicePressed:(NSInteger)tag {
    PostTransactionTableViewCell *cell = (PostTransactionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];

    NSDictionary *postTransaction = [self.postTransactions objectAtIndex:tag];
    
    charterId = [postTransaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    [self performSegueWithIdentifier:kPostTransactionalViewControllerToInvoiceViewControllerSegue sender:self];

    
//    NSArray *invoices = [postTransaction objectForKey:@"invoices"];
//    if (invoices && ![invoices isKindOfClass:[NSNull class]]) {
//        NSDictionary *status = [postTransaction objectForKey:@"status"];
//        if (status && ![status isKindOfClass:[NSNull class]]) {
//            NSDictionary *status2 = [status objectForKey:@"status"];
//            statusDescription = [status2 objectForKey:@"description"];
//        }
//        currentStatus = cell.labelStatus.text;
//        currentDate = cell.labelTime.text;
//        nameAndTime = [NSString stringWithFormat:@"%@ %@", cell.labelName.text,cell.labelTime.text];
   // }
//    else {
//        [SVProgressHUD showErrorWithStatus:@"Error:\nThere is no invoice to present at this time."];
//    }
}


#pragma mark - SetupUItableViewCell

- (void)setupTableViewCell:(PostTransactionTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTag:indexPath.row];
    
    NSDictionary *postTransaction = [self.postTransactions objectAtIndex:indexPath.row];
    NSString *shipName = [postTransaction objectForKey:@"vessel_name"];
    [cell.labelName setText:shipName.uppercaseString];
    
    NSNumber *locked = [postTransaction objectForKey:@"locked"];
    if ([locked isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [cell.imageViewLock setImage:lockIcon];
    }
    else {
        [cell.imageViewLock setImage:unlockIcon];
    }
    
    NSDictionary *status = [postTransaction objectForKey:@"status"];
    if (![status isKindOfClass:[NSNull class]]) {
        NSDictionary *status2 = [status objectForKey:@"status"];
        NSString *description = [status2 objectForKey:@"description"];
        [cell.labelStatus setText:description.uppercaseString];
        
        //OVO NIJE SIGURNO DA TREBA ODAVDE
        NSString *dateTime = [status objectForKey:@"datetime"];
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        [timeFormat setLocale:twentyFour];
        NSDate *dateFromString = [timeFormat dateFromString:dateTime];
        [timeFormat setDateFormat:@"dd/MM/yy"];
        NSString *dateTimeFinal = [[timeFormat stringFromDate:dateFromString]uppercaseString];
        [cell.labelTime setText:[NSString stringWithFormat:@"%@",dateTimeFinal]];
    }
    else {
        [cell.labelStatus setText:@"STATUS NOT SET"];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.postTransactions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCells.count > 0) {
        for (NSNumber *selection in [self.selectedCells mutableCopy]) {
            if ([indexPath row] == [selection integerValue]) {
                //was 200

                return 200;
            }
        }
    }
    return 116;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PostTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPostTransactionTableViewCellIdentifier forIndexPath:indexPath];
    [self setupTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int selection = (float)indexPath.row;
    [self.selectedCells addObject:[NSNumber numberWithInt:selection]];
    
    PostTransactionTableViewCell *cell = (PostTransactionTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewDropDown setImage:dropDownIconUpBlue];
    
    // animate
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int selection = (float)indexPath.row;
    for (NSNumber *selected in [self.selectedCells mutableCopy]) {
        if ([selected integerValue] == selection) {
            [self.selectedCells removeObject:selected];
        }
    }
    PostTransactionTableViewCell *cell = (PostTransactionTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewDropDown setImage:dropDownIconDownBlue];
    
    // animate
    [tableView beginUpdates];
    [tableView endUpdates];
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
    // Set cell delegate
    [((PostTransactionTableViewCell *)cell) setDelegate:self];
}

#pragma mark - MailComposeControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPostTransactionalViewControllerToCharterPartyViewControllerSegue]) {
        CharterPartyViewController *destViewController = segue.destinationViewController;
        
        destViewController.charterId = charterId;
        destViewController.shipName = nameOfShip;
        destViewController.date = currentDate;
        destViewController.status = currentStatus;
    }
    else if ([segue.identifier isEqualToString:kPostTransactionalViewControllerToStatemantOFFactsViewControllerSegue]) {
        StatemantOFFactsViewController *destViewController = segue.destinationViewController;
        
        destViewController.charterId = charterId;
        destViewController.shipName = nameOfShip;
        destViewController.date = currentDate;
        destViewController.status = currentStatus;
    }
    else if ([segue.identifier isEqualToString:kPostTransactionalViewControllerToInvoiceViewControllerSegue]) {
        InvoiceViewController *destViewController = segue.destinationViewController;
        
        destViewController.shipName = nameOfShip;
        destViewController.status = statusDescription;
        destViewController.time = currentDate;
        destViewController.charterId = charterId;
        
        
//        //destViewController.invoices = sender;
//        destViewController.shipNameAndTime = nameAndTime;
//        destViewController.status = statusDescription;
//        destViewController.time = currentDate;
    }
    else if ([segue.identifier isEqualToString:kPostTransactionalViewControllerToOutstandingClaimsViewControllerSegue]) {
        OutstandingClaimsViewController *destViewController = segue.destinationViewController;
        destViewController.charterId = charterId;
        destViewController.shipName = nameOfShip;
        destViewController.date = currentDate;
        destViewController.status = currentStatus;
    }
    else if ([segue.identifier isEqualToString:kPostTransactionalViewControllerToEmailEnquiryViewControllerSegue]) {
        EmailEnquiryViewController *destViewController = segue.destinationViewController;
        destViewController.isPostChartering = [NSNumber numberWithBool:YES];
        destViewController.isToUser = [NSNumber numberWithBool:YES];
    }
}


- (IBAction)buttonCall:(UIButton *)sender {
    // initialize phone number to call
    NSString *phoneNumber = @"+442037448041";
    
    // Open via URL
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Error:\nYour device can't make a call."];
    }
}

- (IBAction)buttonEmail:(UIButton *)sender {
    if (self.postTransactions.count > 0) {
        [self performSegueWithIdentifier:kPostTransactionalViewControllerToEmailEnquiryViewControllerSegue sender:self];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Error.\n Email enquiry is available only when there is Post Chartering available."];
    }
}

- (IBAction)buttonMenu:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController resizeMenuViewControllerToSize:(CGSize)self.view.frame.size];
    
    // Present the view controller
    [self.frostedViewController presentMenuViewController];
}
@end
