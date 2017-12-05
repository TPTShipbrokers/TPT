//
//  InvoiceViewController.m
//  TPT
//
//  Created by Bosko Barac on 10/15/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "InvoiceViewController.h"
#import "InvoiceTableViewCell.h"
#import "NetworkController.h"
#import "AppDelegate.h"
#import "PDFKBasicPDFViewer.h"
#import "PDFKDocument.h"
@import Firebase;

@interface InvoiceViewController ()
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *selectedDocuments;
@property (strong, nonatomic) NSMutableArray *selectedDocumentnames;
@property (strong, nonatomic) NSMutableArray *invoices;

@end

@implementation InvoiceViewController {
    NSData *invoiceData;
    NSString *fullUrl;
    BOOL enableButtons;
    NSString *filePath;
    BOOL shouldMarkitems;
    BOOL allCellsSelected;
    UIImage *selectedImage;
    UIImage *notSelectedImage;
    NSString *selectedFile;
    NSNumber *charteringId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    [self getCharteringDetails];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
   // NSDictionary *items = [self.invoice objectForKey:@"items"];
    self.items = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUInteger count = self.invoices.count;
    
    //setHeight for UITableView based on the number of rows
    CGFloat height = 40;
    if (((int)height * (int)count) < self.tableView.frame.size.height) {
        [self.tableView setScrollEnabled:NO];
    }
    else {
        [self.tableView setScrollEnabled:YES];
    }
    [self.view layoutIfNeeded];
    
    [FIRAnalytics logEventWithName:@"Invoice"
                        parameters:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)initialSetup {
    
    enableButtons = YES;
   // shouldMarkitems = NO;
    allCellsSelected = NO;
    
    selectedImage = [UIImage imageNamed:@"RadioButtonBlue"];
    notSelectedImage = [UIImage imageNamed:@"RadioButtonGray"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.allowsMultipleSelection = YES;

    [self.labelNameTime setText:self.shipName];
    [self.labelStatus setText:self.status.uppercaseString];
    [self.labelTime setText:self.time];
    
    self.selectedDocuments = [[NSMutableArray alloc] init];
    self.selectedDocumentnames = [[NSMutableArray alloc] init];
}

- (void) getCharteringDetails {
    [[NetworkController sharedInstance] getCharteringDetailsForCharterId:self.charterId WithResponseBlock:^(BOOL success, id response) {
        if (success) {
            //self.details = response;
            NSDictionary *dict = response;
            NSDictionary *dict2 = [dict objectForKey:@"data"];
            self.invoices = [dict2 objectForKey:@"invoice_documentations"];
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

#pragma mark - SetupUItableViewCell

- (void)setupTableViewCell:(InvoiceTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTag:indexPath.row];
    
    NSDictionary *invoice = [self.invoices objectAtIndex:indexPath.row];
    charteringId = [invoice objectForKey:@"chartering_id"];
    NSString *fileName = [invoice objectForKey:@"filename"];
    if (fileName && ![fileName isKindOfClass:[NSNull class]]) {
        [cell.labelName setText:fileName];
    }
    else {
        [cell.labelName setText:@"NO FILE"];
    }
    NSLog(@"%@", self.invoices);

    NSString *file = [invoice objectForKey:@"file"];
    NSArray *filepaths = [Settings getinvoicesDocumentationPaths];
    for (NSDictionary *files in filepaths) {
        NSArray *paths = [[NSArray alloc] initWithArray:[files objectForKey:charteringId]];
        for (NSString *path in paths) {
            if ([path isEqualToString:fileName]) {
                [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
                [cell setSelected:YES];
                
                if (![file isKindOfClass:[NSNull class]] && file != nil) {
                    NSString* encodedUrl = [file stringByAddingPercentEscapesUsingEncoding:
                                            NSUTF8StringEncoding];
                    NSString *fullURL = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
                    if (![self.selectedDocuments containsObject:fullURL]) {
                        [self.selectedDocuments addObject:fullURL];
                        [self.selectedDocumentnames addObject:fileName];
                    }
                }
            }
            else {
                [cell setSelected:NO];
            }
        }
    }
    
    if (cell.selected) {
        [cell.imageViewCheckBox setImage:selectedImage];
        [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    }
    else {
        [cell.imageViewCheckBox setImage:notSelectedImage];
        [cell.labelName setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    }
}

- (void) restrictRotation:(BOOL) restriction {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.invoices.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InvoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInvoiceTableViewCellIdentifier forIndexPath:indexPath];
    [self setupTableViewCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InvoiceTableViewCell *cell = (InvoiceTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewCheckBox setImage:selectedImage];
    [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
    
    if (cell.selectionStyle == UITableViewCellSelectionStyleGray) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSDictionary *document = [self.invoices objectAtIndex:indexPath.row];
        NSString *fileName = [document objectForKey:@"filename"];
        charteringId = [document objectForKey:@"chartering_id"];
        if ([fileName isKindOfClass:[NSNull class]]) {
            [SVProgressHUD showErrorWithStatus:@"Error.\nThere is no PDF to show for this Invoice."];
            return;
        }
        
        NSArray *filepaths = [Settings getinvoicesDocumentationPaths];
        for (NSDictionary *files in filepaths) {
            NSArray *paths = [[NSArray alloc] initWithArray:[files objectForKey:charteringId]];
            for (NSString *path in paths) {
                if ([path isEqualToString:fileName]) {
                    NSString *path;
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    path = [documentsDirectory stringByAppendingPathComponent:fileName];
                    selectedFile = path;
                    [self performSegueWithIdentifier:kInvoiceViewControllerToPDFKBasicPDFViewerSegue sender:self];
                }
            }
        }
    }
    else {
        NSDictionary *document = [self.invoices objectAtIndex:indexPath.row];
        
        NSString *filePathX = [document objectForKey:@"file"];
        NSString *fileNameX = [document objectForKey:@"filename"];
        if (![fileNameX isKindOfClass:[NSNull class]]) {
            
            [self.items addObject:@{@"file" : filePathX, @"filename" : fileNameX}];
            
            if (![filePathX isKindOfClass:[NSNull class]] && filePathX != nil) {
                NSString* encodedUrl = [filePathX stringByAddingPercentEscapesUsingEncoding:
                                        NSUTF8StringEncoding];
                NSString *fullURL = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
                if (![self.selectedDocuments containsObject:fullURL]) {
                    [self.selectedDocuments addObject:fullURL];
                    [self.selectedDocumentnames addObject:fileNameX];
                }
            }
            NSLog(@"A%@", self.selectedDocuments);
            [cell setSelected:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InvoiceTableViewCell *cell = (InvoiceTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewCheckBox setImage:notSelectedImage];
    [cell.labelName setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
    
    NSDictionary *document = [self.invoices objectAtIndex:indexPath.row];
    
    NSString *filePathX = [document objectForKey:@"file"];
    NSString *fileNameX = [document objectForKey:@"filename"];
    
    for (NSDictionary *urlDict in [self.items mutableCopy]) {
        NSString *url = [urlDict objectForKey:@"file"];
        if ([url isEqualToString:filePathX]) {
            [self.items removeObject:urlDict];
        }
    }
    
    if (![filePathX isKindOfClass:[NSNull class]] && filePathX != nil) {
        NSString* encodedUrl = [filePathX stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        NSString *fullURL = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
        if ([self.selectedDocuments containsObject:fullURL]) {
            [self.selectedDocuments removeObject:fullURL];
            [self.selectedDocumentnames removeObject:fileNameX];
        }
    }
    NSLog(@"B%@",self.selectedDocuments);
    [cell setSelected:NO];
}

#pragma mark - Private

- (void)markAllInvoices {
    if (!allCellsSelected) {
        allCellsSelected = YES;
        for (int i = 0; i < [self.tableView numberOfSections]; i++) {
            for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSUInteger ints[2] = {i,j};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
                InvoiceTableViewCell *cell = (InvoiceTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

                NSDictionary *invoice = [self.invoices objectAtIndex:indexPath.row];
                
                NSString *fileUrl = [invoice objectForKey:@"file"];
                NSString *fileName = [invoice objectForKey:@"filename"];
                
                if (![fileName isKindOfClass:[NSNull class]]) {
                    if (![fileUrl isKindOfClass:[NSNull class]] && fileUrl != nil) {
                        NSString* encodedUrl = [fileUrl stringByAddingPercentEscapesUsingEncoding:
                                                NSUTF8StringEncoding];
                        NSString *fullURL = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
                        [self.items addObject:@{@"file" : fileUrl, @"filename" : @"Invoice"}];
                        
                        if (![self.selectedDocuments containsObject:fullURL]) {
                            [self.selectedDocuments addObject:fullURL];
                            [self.selectedDocumentnames addObject:fileName];
                        }
                    }
                    [cell setSelected:YES];
                    [cell.imageViewCheckBox setImage:selectedImage];
                    [cell.labelName setTextColor:[UIColor colorWithRed: 2/255.0 green: 83/255.0 blue: 156/255.0 alpha: 1.0]];
                }
            }
        }
    }
    else {
        for (int i = 0; i < [self.tableView numberOfSections]; i++) {
            for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSUInteger ints[2] = {i,j};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
                
                InvoiceTableViewCell *cell = (InvoiceTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                NSDictionary *document = [self.invoices objectAtIndex:indexPath.row];
                
                NSString *filePathX = [document objectForKey:@"file"];
                NSString *fileNameX = [document objectForKey:@"filename"];
                [self.items removeAllObjects];
                
                if (![filePathX isKindOfClass:[NSNull class]] && filePathX != nil) {
                    NSString* encodedUrl = [filePathX stringByAddingPercentEscapesUsingEncoding:
                                            NSUTF8StringEncoding];
                    NSString *fullURL = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
                    if ([self.selectedDocuments containsObject:fullURL]) {
                        [self.selectedDocuments removeObject:fullURL];
                        [self.selectedDocumentnames removeObject:fileNameX];
                    }
                }
                [cell setSelected:NO];
                allCellsSelected = NO;
                [cell.imageViewCheckBox setImage:notSelectedImage];
                [cell.labelName setTextColor:[UIColor colorWithRed: 155/255.0 green: 155/255.0 blue: 155/255.0 alpha: 1.0]];
            }
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kInvoiceViewControllerToPDFKBasicPDFViewerSegue]) {
        //Create the document for the viewer when the segue is performed.
        PDFKBasicPDFViewer *viewer = (PDFKBasicPDFViewer *)segue.destinationViewController;
        viewer.enableBookmarks = YES;
        viewer.enableOpening = YES;
        viewer.enablePrinting = NO;
        viewer.enableSharing = YES;
        viewer.enableThumbnailSlider = YES;
        
        //Load the document
        
        PDFKDocument *document = [PDFKDocument documentWithContentsOfFile:selectedFile password:nil];
        NSLog(@"%@", document);
        
        [viewer loadDocument:document];
        [self restrictRotation:NO];
    }
}
- (IBAction)buttonEmail:(UIButton *)sender {
        if (self.items.count > 0) {
            [SVProgressHUD showWithStatus:@"Sending request..."];
            [[NetworkController sharedInstance] sendEmailToUserWithUrl:@"url" files:self.items WithResponseBlock:^(BOOL success, id response) {
                if (success) {
                    shouldMarkitems = NO;
                    self.tableView.allowsMultipleSelection = NO;
                    [self.buttonMarkAll setHidden:YES];
                    [SVProgressHUD showSuccessWithStatus:@"Request sent."];
                    [self.items removeAllObjects];
                    [self.tableView reloadData];
                }
                else {
                    [SVProgressHUD showErrorWithStatus:@"Error sending request, please try again."];
                }
            }];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"Error.\nNo files selected."];
        }
}

- (IBAction)buttonMarkAll:(UIButton *)sender {
    [self markAllInvoices];
}

- (IBAction)buttonDownload:(UIButton *)sender {
    
    dispatch_group_t pdfDownloadGroup = dispatch_group_create();
    
    for (int i=0; i < self.selectedDocuments.count; i++) {
        dispatch_group_enter(pdfDownloadGroup);
        
        [SVProgressHUD showWithStatus:@"Downloading..."];
        
        NSString *filePathX = [self.selectedDocuments objectAtIndex:i];
        NSString *pathNameOfFile = [self.selectedDocumentnames objectAtIndex:i];
        NSURL *reportURL = [NSURL URLWithString:filePathX];
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
        [Settings addInvoicesPaths:self.selectedDocumentnames forCharteringId:charteringId];
        [self.tableView reloadData];
    });
}
@end
