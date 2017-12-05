//
//  ShipDocumentationViewController.m
//  TPT
//
//  Created by Bosko Barac on 2/25/16.
//  Copyright © 2016 Borne Agency. All rights reserved.
//

#import "ShipDocumentationViewController.h"
#import "ShipDocumentationTableViewCell.h"
#import "NetworkController.h"
#import "PDFKBasicPDFViewer.h"
#import "PDFKDocument.h"
#import "AppDelegate.h"
@import Firebase;

@interface ShipDocumentationViewController ()
@property (strong, nonatomic) NSArray *shipDocuments;
@property (strong, nonatomic) NSMutableArray *selectedDocuments;
@property (strong, nonatomic) NSMutableArray *selectedDocumentnames;
@property (strong, nonatomic) NSMutableArray *itemsToSend;
@end

@implementation ShipDocumentationViewController {
    UIImage *selectedImage;
    UIImage *notSelectedImage;
    NSString *selectedFile;
    BOOL allCellsSelected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FIRAnalytics logEventWithName:@"ShipDocumentation"
                        parameters:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    self.shipDocuments = [[NSArray alloc]init];
    self.selectedDocuments = [[NSMutableArray alloc] init];
    self.selectedDocumentnames = [[NSMutableArray alloc] init];
    self.itemsToSend = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    selectedImage = [UIImage imageNamed:@"RadioButtonBlue"];
    notSelectedImage = [UIImage imageNamed:@"RadioButtonGray"];
    [self.labelName setText:self.name];
    [self.labelStatus setText:self.status];
    [self.labelTime setText:self.time];
    allCellsSelected = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];
    [self getChertaeringDetails];

}

#pragma mark - NSNotificationDelegate

- (void)refreshPages:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        [self getChertaeringDetails];
    }
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

#pragma mark - Private

- (void)getChertaeringDetails {
    [[NetworkController sharedInstance]getCharteringDetailsForCharterId:self.charteringId WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            //self.details = response;
            NSDictionary *dict = response;
            NSDictionary *dict2 = [dict objectForKey:@"data"];
            self.shipDocuments = [dict2 objectForKey:@"ship_documentations"];
            [self.tableView reloadData];
            [self.view layoutIfNeeded];

            NSUInteger count = self.shipDocuments.count;
             
            //setHeight for UITableView based on the number of rows
//            CGFloat height = self.tableView.rowHeight;
//            if (((int)height * (int)count) < self.tableView.frame.size.height) {
//                NSLog(@"1");
//                
//                self.constraintBottomViewBehindTableView.constant = self.constraintBottomViewBehindTableView.constant + (self.tableView.frame.size.height - ((int)height * (int)count));
//                self.constraintBottomTableView.constant = self.constraintBottomTableView.constant + (self.tableView.frame.size.height - ((int)height * (int)count));
//                [self.tableView setScrollEnabled:NO];
//            }
//            else {
//                NSLog(@"2 %f",self.tableView.frame.size.height);
//                [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width,self.tableView.frame.size.height)];
//                
//                [self.tableView setScrollEnabled:YES];
//            }
//
//            [self.view layoutIfNeeded];
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

#pragma mark SetupUiITableViewCell

- (void)setupCell:(ShipDocumentationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSDictionary *document = [self.shipDocuments objectAtIndex:indexPath.row];
    NSString *shipDocumentationName = [document objectForKey:@"filename"];
    NSString *file = [document objectForKey:@"file"];

    NSArray *filepaths = [Settings getShipDocumentationPaths];
    for (NSDictionary *files in filepaths) {
        NSArray *paths = [[NSArray alloc] initWithArray:[files objectForKey:self.charteringId]];
        for (NSString *path in paths) {
            if ([path isEqualToString:shipDocumentationName]) {
                [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
                [cell setSelected:YES];
                
                if (![file isKindOfClass:[NSNull class]] && file != nil) {
                    NSString* encodedUrl = [file stringByAddingPercentEscapesUsingEncoding:
                                            NSUTF8StringEncoding];
                    NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
                    if (![self.selectedDocuments containsObject:fullUrl]) {
                        [self.selectedDocuments addObject:fullUrl];
                        [self.selectedDocumentnames addObject:shipDocumentationName];
                    }
                }
            }
            else {
                [cell setSelected:NO];
            }
        }
    }

    [cell.labelName setText:shipDocumentationName];
    
    if (cell.selected) {
        [cell.imageViewRadioButton setImage:selectedImage];
        [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    }
    else {
        [cell.imageViewRadioButton setImage:notSelectedImage];
        [cell.labelName setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.shipDocuments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Return the Height for cell
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShipDocumentationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kShipDocumentationTableViewCellIdentifier forIndexPath:indexPath];
    
    [self setupCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipDocumentationTableViewCell *cell = (ShipDocumentationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewRadioButton setImage:selectedImage];
    [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    if (cell.selectionStyle == UITableViewCellSelectionStyleGray) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSDictionary *document = [self.shipDocuments objectAtIndex:indexPath.row];
        NSString *fileName = [document objectForKey:@"filename"];
        
        if ([fileName isKindOfClass:[NSNull class]]) {
            [SVProgressHUD showErrorWithStatus:@"Error.\nThere is no PDF to show for this Invoice."];
            return;
        }
        
        NSArray *filepaths = [Settings getShipDocumentationPaths];
        for (NSDictionary *files in filepaths) {
            NSArray *paths = [[NSArray alloc] initWithArray:[files objectForKey:self.charteringId]];
            for (NSString *path in paths) {
                if ([path isEqualToString:fileName]) {
                    NSString *path;
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    path = [documentsDirectory stringByAppendingPathComponent:fileName];
                    selectedFile = path;
                    [self performSegueWithIdentifier:kShipDocumentationViewControllerToPDFKBasicPDFViewerSegue sender:self];
                }
            }
        }
    }
    else {
        NSDictionary *document = [self.shipDocuments objectAtIndex:indexPath.row];
        
        NSString *filePath = [document objectForKey:@"file"];
        NSString *fileName = [document objectForKey:@"filename"];
        [self.itemsToSend addObject:@{@"file" : filePath, @"filename" : fileName}];

        if (![filePath isKindOfClass:[NSNull class]] && filePath != nil) {
            NSString* encodedUrl = [filePath stringByAddingPercentEscapesUsingEncoding:
                                    NSUTF8StringEncoding];
            NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
            if (![self.selectedDocuments containsObject:fullUrl]) {
                [self.selectedDocuments addObject:fullUrl];
                [self.selectedDocumentnames addObject:fileName];
            }
        }
        
        NSLog(@"A%@", self.selectedDocuments);
        [cell setSelected:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipDocumentationTableViewCell *cell = (ShipDocumentationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewRadioButton setImage:notSelectedImage];
    [cell.labelName setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    
    NSDictionary *document = [self.shipDocuments objectAtIndex:indexPath.row];
    
    NSString *filePath = [document objectForKey:@"file"];
    NSString *fileName = [document objectForKey:@"filename"];
    
    for (NSDictionary *urlDict in [self.itemsToSend mutableCopy]) {
        NSString *url = [urlDict objectForKey:@"file"];
        if ([url isEqualToString:filePath]) {
            [self.itemsToSend removeObject:urlDict];
        }
    }

    if (![filePath isKindOfClass:[NSNull class]] && filePath != nil) {
        NSString* encodedUrl = [filePath stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
        if ([self.selectedDocuments containsObject:fullUrl]) {
            [self.selectedDocuments removeObject:fullUrl];
            [self.selectedDocumentnames removeObject:fileName];

        }
    }
    NSLog(@"B%@",self.selectedDocuments);
    [cell setSelected:NO];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShipDocumentationViewControllerToPDFKBasicPDFViewerSegue]) {
        //Create the document for the viewer when the segue is performed.
        PDFKBasicPDFViewer *viewer = (PDFKBasicPDFViewer *)segue.destinationViewController;
        viewer.enableBookmarks = YES;
        viewer.enableOpening = YES;
        viewer.enablePrinting = NO;
        viewer.enableSharing = YES;
        viewer.enableThumbnailSlider = YES;
        
        //Load the document
    
        PDFKDocument *document = [PDFKDocument documentWithContentsOfFile:selectedFile password:nil];
        
        [viewer loadDocument:document];
        [self restrictRotation:NO];
    }
}

- (IBAction)buttonDownloadDocuments:(UIButton *)sender {

    dispatch_group_t pdfDownloadGroup = dispatch_group_create();

    for (int i=0; i < self.selectedDocuments.count; i++) {
        dispatch_group_enter(pdfDownloadGroup);

        [SVProgressHUD showWithStatus:@"Downloading..."];

        NSString *filePath = [self.selectedDocuments objectAtIndex:i];
        NSString *pathNameOfFile = [self.selectedDocumentnames objectAtIndex:i];
        NSURL *reportURL = [NSURL URLWithString:filePath];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if ([data length] > 0 && connectionError == nil) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *filepathX = [documentsDirectory stringByAppendingPathComponent:pathNameOfFile];
                
                NSError *error = nil;
                
                if ([data writeToFile:filepathX options:NSDataWritingAtomic error:&error]) {
                    dispatch_group_leave(pdfDownloadGroup);
                    NSLog(@"uspelo");
                } else {
                    dispatch_group_leave(pdfDownloadGroup);
                    // error writing file
                    NSLog(@"Unable to write PDF to %@. Error: %@", filepathX, error);
                }
            }
           
        }];
    }
    dispatch_group_notify(pdfDownloadGroup, dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [Settings addShipDocumentationPaths:self.selectedDocumentnames forShip:self.charteringId];
        [self.tableView reloadData];
    });
    
}

- (IBAction)buttonEmailDocuments:(UIButton *)sender {
    
    [SVProgressHUD showWithStatus:@"Sending request..."];

    [[NetworkController sharedInstance] sendEmailToUserWithUrl:@"url" files:self.itemsToSend WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"Request sent."];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"Error sending request, please try again."];
        }
    }];
}

- (IBAction)buttonMarkAll:(UIButton *)sender {
    if (!allCellsSelected) {
        allCellsSelected = YES;
        for (int i = 0; i < [self.tableView numberOfSections]; i++) {
            for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSUInteger ints[2] = {i,j};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
                ShipDocumentationTableViewCell *cell = (ShipDocumentationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                
                NSDictionary *document = [self.shipDocuments objectAtIndex:indexPath.row];
                
                NSString *filePath = [document objectForKey:@"file"];
                NSString *fileName = [document objectForKey:@"filename"];
                
                if (![fileName isKindOfClass:[NSNull class]]) {
                    if (![filePath isKindOfClass:[NSNull class]] && filePath != nil) {
                        NSString* encodedUrl = [filePath stringByAddingPercentEscapesUsingEncoding:
                                                NSUTF8StringEncoding];
                        NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
                        [self.itemsToSend addObject:@{@"file" : filePath, @"filename" : fileName}];
                        
                        if (![self.selectedDocuments containsObject:fullUrl]) {
                            [self.selectedDocuments addObject:fullUrl];
                            [self.selectedDocumentnames addObject:fileName];
                        }
                    }
                    NSLog(@"%@",self.selectedDocumentnames);
                    [cell.imageViewRadioButton setImage:selectedImage];
                    [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
                    [cell setSelected:YES];
                }
            }
        }
    }
    else {
        for (int i = 0; i < [self.tableView numberOfSections]; i++) {
            for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSUInteger ints[2] = {i,j};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
                
                ShipDocumentationTableViewCell *cell = (ShipDocumentationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.imageViewRadioButton setImage:notSelectedImage];
                [cell.labelName setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
                
                NSDictionary *document = [self.shipDocuments objectAtIndex:indexPath.row];
                
                NSString *filePath = [document objectForKey:@"file"];
                NSString *fileName = [document objectForKey:@"filename"];
                [self.itemsToSend removeAllObjects];

                
                if (![filePath isKindOfClass:[NSNull class]] && filePath != nil) {
                    NSString* encodedUrl = [filePath stringByAddingPercentEscapesUsingEncoding:
                                            NSUTF8StringEncoding];
                    NSString *fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
                    if ([self.selectedDocuments containsObject:fullUrl]) {
                        [self.selectedDocuments removeObject:fullUrl];
                        [self.selectedDocumentnames removeObject:fileName];
                    }
                }
                NSLog(@"B%@",self.selectedDocuments);
                [cell setSelected:NO];
                allCellsSelected = NO;
            }
        }
    }
}
@end
