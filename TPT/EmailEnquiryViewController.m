//
//  EmailEnquiryViewController.m
//  TPT
//
//  Created by Boshko Barac on 12/9/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "EmailEnquiryViewController.h"
#import "EmailEnquiryTableViewCell.h"
#import "NetworkController.h"
#import "AppDelegate.h"
@import Firebase;

@interface EmailEnquiryViewController ()
@property (strong, nonatomic) NSMutableArray *optionalItems;
@end

@implementation EmailEnquiryViewController {
    NSString *emailContent;
    NSString *laycan;
    NSString *volume;
    NSString *cargo;
    NSString *loadPort;
    NSString *dischargePort;
    NSString *draft;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"EmailEnquiry"
                        parameters:nil];
}

- (void)initialSetup {
    
    if ([self.isComingFromClaims isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self.labelTo setText:@"TPT CLAIMS"];
        [self.labelSubject setText:[NSString stringWithFormat:@"%@ REQUEST FOR FULL CLAIM DETAILS",self.shipName.uppercaseString]];
        [self.textView scrollRangeToVisible:[self.textView selectedRange]];
        [self.textView setDelegate:self];
        NSString *userFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userFullName"];
        NSString *userEmailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];

        [self.labelFrom setText:userFullName.uppercaseString];
        emailContent = [NSString stringWithFormat:@"Dear TPT,\n\nI am contacting you with the request for full claim details for %@.\nYou can send me Claim details on %@\n\nRegards,\n%@",self.shipName.uppercaseString ,userEmailAddress, userFullName];
        [self.textView setText:emailContent];
        [self.labelShipName setText:self.shipName];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else if ([self.isToUser isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        if ([self.isPostChartering isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            [self.labelTo setText:@"BROKER"];
            [self.labelSubject setText:@"POST CHARTERING ENQUIRY"];
            [self.textView scrollRangeToVisible:[self.textView selectedRange]];
            [self.textView setDelegate:self];
            NSString *userFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userFullName"];
            NSString *userEmailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];
            
            [self.labelFrom setText:userFullName.uppercaseString];
            emailContent = [NSString stringWithFormat:@"Dear TPT,\n\nI am contacting you with the request for more details about Post Chartering.\nYou can send me Post Chartering details on %@\n\nRegards,\n%@",userEmailAddress, userFullName];
            [self.textView setText:emailContent];
            [self.labelShipName setText:self.shipName];
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        else {
            [self.labelTo setText:@"BROKER"];
            [self.labelSubject setText:@"CHARTERING ENQUIRY"];
            [self.textView scrollRangeToVisible:[self.textView selectedRange]];
            [self.textView setDelegate:self];
            NSString *userFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userFullName"];
            NSString *userEmailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];
            
            [self.labelFrom setText:userFullName.uppercaseString];
            emailContent = [NSString stringWithFormat:@"Dear TPT,\n\nI am contacting you with the request for more details about Chartering.\nYou can send me Chartering details on %@\n\nRegards,\n%@",userEmailAddress, userFullName];
            [self.textView setText:emailContent];
            [self.labelShipName setText:self.shipName];
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    else {
        self.optionalItems = [[NSMutableArray alloc]initWithObjects:@"LAYCAN…",@"VOLUME…", @"CARGO…",@"LOAD PORT…",@"DISCHARGE PORT…",@"DRAFT…", nil];
        [self.textView scrollRangeToVisible:[self.textView selectedRange]];
        [self.textView setDelegate:self];
        NSString *userFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userFullName"];
        [self.labelFrom setText:userFullName.uppercaseString];
        emailContent = [NSString stringWithFormat:@"Dear TPT,\n\nI was browsing your positions list via your mobile application and I understand that %@ will open on the %@. I’m interested to know more. Please call me to discuss.\n\nRegards,\n%@",self.shipName.uppercaseString ,self.dateAvailable, userFullName];
        [self.textView setText:emailContent];
        [self.labelShipName setText:self.shipName];
        
        [self.labelSubject setText:[NSString stringWithFormat:@"%@ OPEN LIST ENQUIRY",self.shipName.uppercaseString]];
        
        laycan = @"";
        volume = @"";
        cargo = @"";
        loadPort = @"";
        dischargePort = @"";
        draft = @"";
    }
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

#pragma mark - SetupUItableViewCell

- (void)setupTableViewCell:(EmailEnquiryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textField setTag:indexPath.row];
    NSString *option = [self.optionalItems objectAtIndex:indexPath.row];
    cell.textField.delegate = self;
    [cell.labelOption setText:option];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.optionalItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([self.isComingFromClaims isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        //Create custom view and place label for header
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width, 20)];
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *objLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,tableView.bounds.size.width ,20)];
        [objLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
        [objLabel setTextColor:[UIColor colorWithRed: 211/255.0 green: 209/255.0 blue: 209/255.0 alpha: 1.0]];
        [objLabel setText:@"optional..."];
        [headerView addSubview: objLabel];
        return headerView;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width, 20)];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EmailEnquiryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEmailEnquiryTableViewCellIdentifier forIndexPath:indexPath];
    [self setupTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //EmailEnquiryTableViewCell *cell = (EmailEnquiryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {

    // Make sure to set the label to have a ta
    if (textField.tag == 0) {
        NSLog(@"%@",textField.text);
        laycan = textField.text;
    }
    else if (textField.tag == 1) {
        NSLog(@"%@",textField.text);
        volume = textField.text;
    }
    else if (textField.tag == 2) {
        NSLog(@"%@",textField.text);
        cargo = textField.text;
    }
    else if (textField.tag == 3) {
        NSLog(@"%@",textField.text);
        loadPort = textField.text;
    }
    else if (textField.tag == 4) {
        NSLog(@"%@",textField.text);
        dischargePort = textField.text;
    }
    else if (textField.tag == 5) {
        NSLog(@"%@",textField.text);
        draft = textField.text;
    }
}

- (IBAction)buttonEnquiry:(UIButton *)sender {
    
    [SVProgressHUD showWithStatus:@"Sending Email..."];
    NSString *finalContent;
    NSString *saveString = [self.textView.text stringByReplacingOccurrencesOfString: @"\n" withString: @"<br>"];

    if (laycan.length > 0 || volume.length > 0 || cargo.length > 0 || loadPort.length > 0 || dischargePort.length > 0 || draft.length > 0) {
        NSString *content = [NSString stringWithFormat:@"%@\n\nAditional:\nLaycan: %@\nVolume: %@\nCargo: %@\nLoad Port: %@\nDischarge Port: %@\nDraft: %@",saveString,laycan,volume,cargo,loadPort,dischargePort,draft];
        finalContent = [content stringByReplacingOccurrencesOfString: @"\n" withString: @"<br>"];

    }
    else {
        finalContent = saveString;
    }
    
    [[NetworkController sharedInstance] sendEmailToAdminWithText:finalContent fileName:@"TPT Enquiry" subject:self.labelSubject.text WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"Email sent."];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSLog(@"%@", response);
            [SVProgressHUD showErrorWithStatus:@"Error sending email. Please, try again."];
        }
    }];
}
@end
