//
//  ContactViewController.m
//  TPT
//
//  Created by Bosko Barac on 12/17/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactListTableViewCell.h"
#import "NetworkController.h"
#import "AppDelegate.h"
#import "CNContactViewControllerSub.h"
@import Firebase;

@interface ContactViewController ()
@property (strong, nonatomic) NSMutableArray *teamMembers;
@property (strong , nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *allContacts;
@property (strong, nonatomic) CNMutableContact *saveContact;
@end

@implementation ContactViewController {
    BOOL isEdit;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self setUpRefreshControl];
    [self refreshContacts];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTintColor: [UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTintColor: [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [FIRAnalytics logEventWithName:@"Contacts"
                        parameters:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    isEdit = NO;
    self.teamMembers = [[NSMutableArray alloc] init];
    self.allContacts = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

#pragma mark - NSNotificationDelegate

- (void)refreshPages:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        [self refreshContacts];
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
    [self refreshContacts];
}

- (void)refreshContacts {
    //Load Newsletters
    [SVProgressHUD showWithStatus:@"Loading contacts..."];
    [[NetworkController sharedInstance] getAllTeamMembersWithResponseBlock:^(BOOL success, id response) {
        if (success) {
            self.teamMembers = response;
            [SVProgressHUD dismiss];
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
                [SVProgressHUD showErrorWithStatus:@"Error:\nError loading contacts, please pull down to refresh."];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                NSLog(@"%@", response);
            }
        }
    }];
}

#pragma mark - SetupUItableViewCell

- (void)setupTableViewCell:(ContactListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTag:indexPath.row];
    
    NSDictionary *member = [self.teamMembers objectAtIndex:indexPath.row];
    NSString *email = [member objectForKey:@"email"];
    //NSString *email2 = [member objectForKey:@"email2"];
    NSString *firstName = [member objectForKey:@"first_name"];
    NSString *lastName = [member objectForKey:@"last_name"];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
    NSString *phoneNumber = [member objectForKey:@"phone"];
    NSString *phoneNumber2 = [member objectForKey:@"phone2"];
    NSString *position = [member objectForKey:@"position"];
    NSString *imageUrl = [member objectForKey:@"profile_picture"];
    NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",imageUrl];
    NSString* encodedUrl;
    if (fullUrl && ![fullUrl isKindOfClass:[NSNull class]]) {
        encodedUrl = [fullUrl stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
    }

    NSURL *imageURL = [NSURL URLWithString:encodedUrl];
    NSLog(@"%@",fullUrl);
    
    if (imageURL && ![imageURL isKindOfClass:[NSNull class]]) {
    [cell.imageViewProfilePicture sd_setImageWithURL:imageURL];
    }
    if (![fullName isKindOfClass:[NSNull class]]) {
        [cell.labelName setText:fullName];
    }
    if (![email isKindOfClass:[NSNull class]]) {
        [cell.labelEmail1 setText:email];
    }
//    if (![email2 isEqual:[NSNull null]]) {
//        [cell.labelEmail2 setText:email2];
//    }
    [cell.labelPhone1 setText:phoneNumber];
    if (![phoneNumber2 isKindOfClass:[NSNull class]]) {
        [cell.labelPhone2 setText:phoneNumber2];
    }
    if (position && ![position isKindOfClass:[NSNull class]]) {
        [cell.labelPosition setText:position];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.teamMembers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactListTableViewCellIdentifier forIndexPath:indexPath];
    [self setupTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    ContactListTableViewCell *cell = (ContactListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    // Collect user info from cell and save it to phone memory
    NSString *name = cell.labelName.text;
    NSString *homeNumber = cell.labelPhone1.text;
    NSString *mobileNumber = cell.labelPhone2.text;
    NSString *firstEmail = cell.labelEmail1.text;
    NSString * secondEmail = @"";
    UIImage *profileImage = cell.imageViewProfilePicture.image;
    [self saveContactToAddressBookWithName:name homeNumber:homeNumber mobileNumber:mobileNumber firstEmail:firstEmail secondEmail:secondEmail andImage:profileImage];
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

#pragma mark - Private

- (void)saveContactToAddressBookWithName:(NSString *)name homeNumber:(NSString *)homeNumber mobileNumber:(NSString *)mobileNumber firstEmail:(NSString *)firstEmail secondEmail:(NSString *)secondEmail andImage:(UIImage *)image {
    
    CNContactStore * store = [[CNContactStore alloc]init];
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
        }];
    }
    else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusDenied) {
        [SVProgressHUD showInfoWithStatus:@"Access is denied, go to Your phone settings and allow the app to access contacts."];
    }
    else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {

        NSArray * nameArray = [name componentsSeparatedByString:@" "];
        NSString *firstName = [nameArray objectAtIndex:0];
        NSString *lastName;
        if (nameArray.count > 1) {
            lastName = [nameArray objectAtIndex:1];
        }
        
        // create contact
        
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.givenName = firstName;
        
        if (lastName && lastName.length > 0 && ![lastName isEqualToString:@""]) {
            contact.familyName = lastName;
        }
        
        CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:homeNumber]];
        if (mobileNumber && mobileNumber.length > 0 && ![mobileNumber isEqualToString:@""]) {
            CNLabeledValue *mobilePhone = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:[CNPhoneNumber phoneNumberWithStringValue:mobileNumber]];
            contact.phoneNumbers = @[homePhone, mobilePhone];
        }
        else {
            contact.phoneNumbers = @[homePhone];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        
        if (imageData && imageData.length > 0) {
            contact.imageData = imageData;
        }
        
        CNLabeledValue *email1 = [CNLabeledValue labeledValueWithLabel:CNLabelEmailiCloud value:firstEmail];
        
        if (secondEmail && secondEmail.length > 0 && ![secondEmail isEqualToString:@""]) {
            CNLabeledValue *email2 = [CNLabeledValue labeledValueWithLabel:CNLabelEmailiCloud value:secondEmail];
            contact.emailAddresses = @[email1, email2];
        }
        else {
            contact.emailAddresses = @[email1];
        }
        contact.organizationName = @"TPT";
        
        NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey,CNContactEmailAddressesKey,CNContactPhoneNumbersKey,[CNContactViewController descriptorForRequiredKeys]];
        NSPredicate *predicate = [CNContact predicateForContactsMatchingName:[NSString stringWithFormat:@"%@ %@",contact.givenName, contact.familyName]];
        NSError *error;
        NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
        if (error) {
            NSLog(@"error fetching contacts %@", error);
        }
        else {
            if (cnContacts.count > 0) {
                for (CNContact *contactX in cnContacts) {
                    if ([contactX.givenName isEqualToString:contact.givenName] && [contactX.familyName isEqualToString:contact.familyName]) {
                        isEdit = YES;
                        CNContactViewController *controller = [CNContactViewController viewControllerForContact:contactX];

                        controller.allowsEditing = YES;
                        controller.delegate = self;
                            [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
                        [self.navigationController.navigationBar setTintColor: [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0f]];
                       // [[UIBarButtonItem appearance] setTintColor: [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0f]];
                        [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
                        [self.navigationController showViewController:controller sender:self];
                    }
                }
            }
            else {
                isEdit = NO;
                CNContactViewControllerSub *controller = [CNContactViewControllerSub viewControllerForNewContact:contact];
                controller.allowsEditing = YES;
                controller.delegate = self;
                self.saveContact = contact;
               [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
                [self.navigationController.navigationBar setTintColor: [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0f]];
                [[UIBarButtonItem appearance] setTintColor: [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0f]];
                [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
                [self.navigationController showViewController:controller sender:self];
            }
        }
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Error:\nCan't save new contact, access to phonebook denied."];
    }
}

- (void)barButtonBackPressed {
}

-(BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property {
    return NO;
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(CNContact *)contact {
    if (!isEdit) {
        CNContactStore * store = [[CNContactStore alloc]init];
        
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
        [saveRequest addContact:self.saveContact toContainerWithIdentifier:[store defaultContainerIdentifier]];
        [store executeSaveRequest:saveRequest error:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
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
