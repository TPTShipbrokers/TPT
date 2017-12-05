//
//  CharteringListViewController.m
//  TPT
//
//  Created by Boshko Barac on 12/9/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "CharteringListViewController.h"
#import "CharteringTableViewCell.h"
#import "NetworkController.h"
#import "CharterPartyViewController.h"
#import "StatemantOFFactsViewController.h"
#import "PDFKBasicPDFViewer.h"
#import "PDFKDocument.h"
#import "AppDelegate.h"
#import "ShipDocumentationViewController.h"
#import "EmailEnquiryViewController.h"
#import "InvoiceViewController.h"
@import Firebase;

@interface CharteringListViewController () <CharteringTableViewCellDelegate>
@property (strong, nonatomic) NSMutableArray *selectedCells;
@property (strong, nonatomic) NSMutableArray *charteringList;
@property (strong , nonatomic) UIRefreshControl *refreshControl;
@end

@implementation CharteringListViewController {
    UIImage *dropDownIconUpBlue;
    UIImage *dropDownIconDownBlue;
    NSString *charterId;
    NSString *nameOfShip;
    NSString *currentStatus;
    NSString *currentDate;
    NSString *fullUrl;
    NSString *filePath;
    NSString *nameAndTime;
    NSString *statusDescription;
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
    [FIRAnalytics logEventWithName:@"Chartering"
                        parameters:nil];
}

- (void)initialSetup {
    self.selectedCells = [[NSMutableArray alloc]init];
    self.charteringList = [[NSMutableArray alloc]init];
    self.tableView.allowsMultipleSelection = YES;
    
    dropDownIconDownBlue = [UIImage imageNamed:@"BlueDropDownIcon"];
    dropDownIconUpBlue = [UIImage imageNamed:@"BlueDropDownIconUp"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeOrientation:)
                                                 name:kChangeOrientationToPortraitNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (void)changeOrientation:(NSNotification *)notification {
    [self restrictRotation:YES];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationMaskPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
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
    
    [[NetworkController sharedInstance] getCharteringListWithResponseBlock:^(BOOL success, id response) {
        if (success) {
            [SVProgressHUD dismiss];
            self.charteringList = response;
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
            NSLog(@"%@", response);
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
                [SVProgressHUD showErrorWithStatus:@"There is no results for chartering."];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                NSLog(@"%@", response);
            }
        }
    }];
}

#pragma mark - CharteringTableViewCellDelegate

- (void)StatemantOfFactsPressed:(NSInteger)tag {
    CharteringTableViewCell *cell = (CharteringTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    NSDictionary *transaction = [self.charteringList objectAtIndex:tag];
    charterId = [transaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelShipName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    
    [self performSegueWithIdentifier:kCharteringListViewControllerToStatemantOFFactsViewControllerSegue sender:self];
}

- (void)CharterPartyPressed:(NSInteger)tag {
    CharteringTableViewCell *cell = (CharteringTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    NSDictionary *transaction = [self.charteringList objectAtIndex:tag];
    charterId = [transaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelShipName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    
    [self performSegueWithIdentifier:kCharteringListViewControllerToCharterPartyViewControllerSegue sender:self];
}

- (void)InvoicePressed:(NSInteger)tag {
    CharteringTableViewCell *cell = (CharteringTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    
    NSDictionary *postTransaction = [self.charteringList objectAtIndex:tag];
    
    charterId = [postTransaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelShipName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    [self performSegueWithIdentifier:kCharteringListViewControllerToInvoiceViewControllerSegue sender:self];

//    NSArray *invoices = [postTransaction objectForKey:@"invoices"];
//    if (invoices && ![invoices isKindOfClass:[NSNull class]]) {
//        NSDictionary *status = [postTransaction objectForKey:@"status"];
//        if (status && ![status isKindOfClass:[NSNull class]]) {
//            NSDictionary *status2 = [status objectForKey:@"status"];
//            statusDescription = [status2 objectForKey:@"description"];
//        }
//        currentStatus = cell.labelStatus.text;
//        currentDate = cell.labelTime.text;
//        nameAndTime = [NSString stringWithFormat:@"%@ %@", cell.labelShipName.text,cell.labelTime.text];
//    }
//    else {
//        [SVProgressHUD showErrorWithStatus:@"Error:\nThere is no invoice to present at this time."];
//    }
}

- (void)DocumentationPressed:(NSInteger)tag {
    CharteringTableViewCell *cell = (CharteringTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];

    NSDictionary *transaction = [self.charteringList objectAtIndex:tag];
    charterId = [transaction objectForKey:@"chartering_id"];
    nameOfShip = cell.labelShipName.text;
    currentDate = cell.labelTime.text;
    currentStatus = cell.labelStatus.text;
    
    [self performSegueWithIdentifier:kCharteringListViewControllerToShipDocumentationViewControllerSegue sender:self];
    
    // NSDictionary *transaction = [self.charteringList objectAtIndex:tag];
    
    //Get url of Pdf and save it to file
   // [SVProgressHUD showWithStatus:@"Loading Newsletter..."];
   // NSString *reportUrl = [transaction objectForKey:@"ship_documentation"];
   // NSLog(@"%@", reportUrl);
   
   // if (![reportUrl isEqual:[NSNull null]] && reportUrl != nil) {
     //   NSString* encodedUrl = [reportUrl stringByAddingPercentEscapesUsingEncoding:
                              //  NSUTF8StringEncoding];
    //    fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
    //    NSURL *reportURL = [NSURL URLWithString:fullUrl];
    //    NSLog(@"%@", fullUrl);
    //
     //   NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
    //    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
     //   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
       // NSString *documentsDirectory = [paths objectAtIndex:0];
       // filePath = [documentsDirectory stringByAppendingPathComponent:@"MyDocument.pdf"];
        
       // NSError *error = nil;
        //[self removeFile];
       // if ([data writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            //[self performSegueWithIdentifier:kCharteringListViewControllerToPDFKBasicPDFViewerSegue sender:self];
       // } else {
            // error writing file
           // NSLog(@"Unable to write PDF to %@. Error: %@", filePath, error);
       // }
       // [SVProgressHUD dismiss];
   // }
    //else {
    //    [SVProgressHUD showErrorWithStatus:@"There is no documentation for this ship."];
     //   return;
   // }
}

- (void)PlanPressed:(NSInteger)tag {
    NSDictionary *transaction = [self.charteringList objectAtIndex:tag];
    
    //Get url of Pdf and save it to file
    [SVProgressHUD showWithStatus:@"Loading Newsletter..."];
    NSString *reportUrl = [transaction objectForKey:@"stowage_plan"];
    NSLog(@"%@", reportUrl);

    if (![reportUrl isKindOfClass:[NSNull class]] && reportUrl != nil) {
        NSString* encodedUrl = [reportUrl stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
        NSURL *reportURL = [NSURL URLWithString:fullUrl];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        filePath = [documentsDirectory stringByAppendingPathComponent:@"MyDocument.pdf"];
        
        NSError *error = nil;
        //[self removeFile];
        if ([data writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            [self performSegueWithIdentifier:kCharteringListViewControllerToPDFKBasicPDFViewerSegue sender:self];
        } else {
            // error writing file
            NSLog(@"Unable to write PDF to %@. Error: %@", filePath, error);
        }
        [SVProgressHUD dismiss];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"There is no stowage plan at this time."];
        return;
    }
}

#pragma mark - Schedule Notification 

- (void)scheduleNotificationforDate:(NSDate *)date andAlertText:(NSString *)alertText {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = date;
    notification.alertBody = alertText;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - SetupUItableViewCell

- (void)setupTableViewCell:(CharteringTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTag:indexPath.row];
    
    NSDictionary *transaction = [self.charteringList objectAtIndex:indexPath.row];
    
    NSString *shipName = [transaction objectForKey:@"vessel_name"];
    [cell.labelShipName setText:shipName.uppercaseString];
    
    NSDictionary *status = [transaction objectForKey:@"status"];
    NSString *subsDueTime = [transaction objectForKey:@"subs_due"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [timeFormat setLocale:twentyFour];
    NSDate *dateFromString = [timeFormat dateFromString:subsDueTime];
    [timeFormat setDateFormat:@"HH:mm"];
    NSString *theTime = [timeFormat stringFromDate:dateFromString];
    [timeFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *state = [transaction objectForKey:@"state"];
    
    if (state && ![state isKindOfClass:[NSNull class]]) {
        if ([state isEqualToString:@"subs_due"]) {
            [cell.imageViewShip setHidden:YES];
            [cell.imageViewClock setHidden:NO];
            //TEMPORARY
            [cell.imageViewSmallClock setHidden:YES];
            [cell.labelTime setHidden:YES];
            
            [cell.labelTimeLeft setHidden:NO];
            [cell.imageViewCountDownClock setHidden:NO];
            
            NSDate *nowDate = [NSDate date];
            NSString *theDate = [timeFormat stringFromDate:nowDate];
            NSDate *finalDate = [timeFormat dateFromString:theDate];
            
            
            if( [[timeFormat stringFromDate:nowDate] isEqualToString:[timeFormat stringFromDate:dateFromString]] ) {
                //[cell.labelTimeLeft setText:[NSString stringWithFormat:@"%@ HRS (GMT) TODAY",theTime]];
                [cell.labelTimeLeft setText:[NSString stringWithFormat:@"SUBS DUE: %@",[self updateTimerWithDate:dateFromString isToday:YES]]];

                NSDate *notificationDate15MinutesBefore = [dateFromString dateByAddingTimeInterval:-60*15];
                NSDate *notificationDate1MinuteBefore = [dateFromString dateByAddingTimeInterval:-60*1 - 59];

                [self scheduleNotificationforDate:notificationDate15MinutesBefore andAlertText:[NSString stringWithFormat:@"Subs almost due for %@", shipName]];
                [self scheduleNotificationforDate:notificationDate1MinuteBefore andAlertText:[NSString stringWithFormat:@"Subs due for %@", shipName]];
            }
            else {
                [cell.labelTimeLeft setText:[NSString stringWithFormat:@"SUBS DUE: %@",[self updateTimerWithDate:dateFromString isToday:NO]]];
                
            }
            if (![status isKindOfClass:[NSNull class]]) {
                NSDictionary *status2 = [status objectForKey:@"status"];
                NSString *statusDescription = [status2 objectForKey:@"description"];
                [cell.labelStatus setText:statusDescription.uppercaseString];
            }
            else {
                [cell.labelStatus setText:@"STATUS NOT SET"];
            }
        }
        else if ([state isEqualToString:@"live"]){
            [cell.imageViewShip setHidden:NO];
            [cell.imageViewClock setHidden:YES];
            
            if (![status isKindOfClass:[NSNull class]]) {
                NSDictionary *status2 = [status objectForKey:@"status"];
                NSString *statusDescription = [status2 objectForKey:@"description"];
                [cell.labelStatus setText:statusDescription.uppercaseString];
            }
            else {
                [cell.labelStatus setText:@"STATUS NOT SET"];
            }
            [cell.imageViewShip setHidden:NO];
            [cell.imageViewClock setHidden:YES];
            NSString *fullTime = [timeFormat stringFromDate:dateFromString];
            [cell.labelTime setText:[NSString stringWithFormat:@"Clean Fixed - CPD %@",fullTime]];
            
            //TEMPORARY
            [cell.imageViewSmallClock setHidden:NO];
            [cell.labelTime setHidden:NO];
            [cell.labelTimeLeft setHidden:YES];
            [cell.imageViewCountDownClock setHidden:YES];
        }
        else if ([state isEqualToString:@"subs_failed"]) {
            [cell.imageViewShip setHidden:YES];
            [cell.imageViewClock setHidden:NO];
            [cell.labelTimeLeft setText:[NSString stringWithFormat:@"SUBS FAILED"]];
            [cell.labelStatus setHidden:YES];
            
            //TEMPORARY
            [cell.imageViewSmallClock setHidden:YES];
            [cell.labelTime setHidden:YES];
            [cell.labelTimeLeft setHidden:NO];
            [cell.imageViewCountDownClock setHidden:NO];
        }
    }
    else {
        [cell.imageViewShip setHidden:NO];
        [cell.imageViewClock setHidden:YES];
    }
    
    NSNumber *transactionId = [transaction objectForKey:@"chartering_id"];
    [cell.labelID setText:[NSString stringWithFormat:@"%@",transactionId]];
}

#pragma mark - NSTimer Private

- (NSString *)updateTimerWithDate:(NSDate *)transactionDate isToday:(BOOL)isToday{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:(-5*3600)]];

    NSDate *startingDate = [NSDate date];
    NSDate *endingDate = transactionDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:startingDate toDate:endingDate options:0];
    
    NSInteger days     = [dateComponents day];
    NSInteger hours    = [dateComponents hour];
    NSInteger minutes  = [dateComponents minute];
    
    NSString *countdownText;
    if (isToday) {
        if ( ([transactionDate compare:startingDate]) == NSOrderedDescending ) {
            countdownText = [NSString stringWithFormat:@"%ld HRS %ld MINS",(long)hours, (long)minutes];
        }
        else {
            countdownText = @"";
        }
    }
    else {
        if ( ([transactionDate compare:startingDate]) == NSOrderedDescending ) {
            countdownText = [NSString stringWithFormat:@"%ld DAYS %ld HRS %ld MINS ", (long)days, (long)hours, (long)minutes];
        }
        else {
            countdownText = @"";
        }
    }
    return countdownText;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.charteringList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCells.count > 0) {
        for (NSNumber *selection in [self.selectedCells mutableCopy]) {
            if ([indexPath row] == [selection integerValue]) {
                return 278;
            }
        }
    }
    return 116;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CharteringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCharteringTableViewCellIdentifier forIndexPath:indexPath];
    [self setupTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int selection = (float)indexPath.row;
    [self.selectedCells addObject:[NSNumber numberWithInt:selection]];
    
    CharteringTableViewCell *cell = (CharteringTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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
    CharteringTableViewCell *cell = (CharteringTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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
    
    [((CharteringTableViewCell *)cell) setDelegate:self];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kCharteringListViewControllerToStatemantOFFactsViewControllerSegue]) {
        StatemantOFFactsViewController *destViewController = segue.destinationViewController;
        destViewController.charterId = charterId;
        destViewController.shipName = nameOfShip;
        destViewController.date = currentDate;
        destViewController.status = currentStatus;
    }
    else if ([segue.identifier isEqualToString:kCharteringListViewControllerToCharterPartyViewControllerSegue]) {
        CharterPartyViewController *destViewController = segue.destinationViewController;
        destViewController.charterId = charterId;
        destViewController.shipName = nameOfShip;
        destViewController.date = currentDate;
        destViewController.status = currentStatus;
    }
    else if ([segue.identifier isEqualToString:kCharteringListViewControllerToPDFKBasicPDFViewerSegue]) {
        //Create the document for the viewer when the segue is performed.
        PDFKBasicPDFViewer *viewer = (PDFKBasicPDFViewer *)segue.destinationViewController;
        viewer.enableBookmarks = YES;
        viewer.enableOpening = YES;
        viewer.enablePrinting = NO;
        viewer.enableSharing = YES;
        viewer.enableThumbnailSlider = YES;
        
        //Load the document
        PDFKDocument *document = [PDFKDocument documentWithContentsOfFile:filePath password:nil];
        [viewer loadDocument:document];
        
        [self restrictRotation:NO];
    }
    else if ([segue.identifier isEqualToString:kCharteringListViewControllerToShipDocumentationViewControllerSegue]) {
        ShipDocumentationViewController *destViewController = segue.destinationViewController;
        destViewController.name = nameOfShip;
        destViewController.time = currentDate;
        destViewController.status = currentStatus;
        destViewController.charteringId = charterId;
    }
    
    else if ([segue.identifier isEqualToString:kCharteringListViewControllerToEmailEnquiryViewControllerSegue]) {
        EmailEnquiryViewController *destViewController = segue.destinationViewController;
        destViewController.isToUser = [NSNumber numberWithBool:YES];
    }
    else if ([segue.identifier isEqualToString:kCharteringListViewControllerToInvoiceViewControllerSegue]) {
        InvoiceViewController *destViewController = segue.destinationViewController;
        //destViewController.invoices = sender;
        destViewController.shipName = nameOfShip;
        destViewController.status = statusDescription;
        destViewController.time = currentDate;
        destViewController.charterId = charterId;
    }
}

#pragma mark - IBActions

- (IBAction)buttonEmail:(UIButton *)sender {
//    // Email Subject
//    NSString *emailTitle = @"Chartering Enquiry";
//    // Email Content
//    NSString *messageBody = @"";
//    // To address
//    NSArray *toRecipents = [NSArray arrayWithObject:@"chartering@tunept.com"];
//    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
//    
//    
//    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
//    mc.mailComposeDelegate = self;
//    [mc setSubject:emailTitle];
//    [mc setMessageBody:messageBody isHTML:NO];
//    [mc setToRecipients:toRecipents];
//    
//    // Present mail view controller on screen
//    [self presentViewController:mc animated:YES completion:NULL];
    
    if (self.charteringList.count > 0) {
        [self performSegueWithIdentifier:kCharteringListViewControllerToEmailEnquiryViewControllerSegue sender:self];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Error.\n Email enquiry is available only when there is Chartering available."];
    }
}

- (IBAction)buttonCall:(UIButton *)sender {
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

- (IBAction)buttonMenu:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController resizeMenuViewControllerToSize:(CGSize)self.view.frame.size];
    
    // Present the view controller
    [self.frostedViewController presentMenuViewController];
}
@end
