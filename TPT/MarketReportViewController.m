//
//  MarketReportViewController.m
//  TopFenders
//
//  Created by Bosko Barac on 11/27/15.
//  Copyright © 2015 Borne. All rights reserved.
//

#import "MarketReportViewController.h"
#import "NetworkController.h"
#import "MarketReportTableViewCell.h"
#import "PDFKBasicPDFViewer.h"
#import "PDFKDocument.h"
#import "AppDelegate.h"

@interface MarketReportViewController ()
@property (strong, nonatomic) NSMutableArray *marketReports;
@property (strong , nonatomic) UIRefreshControl *refreshControl;
@end

@implementation MarketReportViewController {
    NSData *reportData;
    NSString *fullUrl;
    NSString *filePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restrictRotation:YES];
    [self initialSetup];
    [self setUpRefreshControl];
    [self refreshNewsLetters];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialSetup {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.marketReports = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeOrientation:)
                                                 name:kChangeOrientationToPortraitNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPages:)
                                                 name:kRefreshPagesNotification
                                               object:nil];
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
        [self refreshNewsLetters];
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
    [self refreshNewsLetters];
}

- (void)refreshNewsLetters {
    //Load Newsletters
    [SVProgressHUD showWithStatus:@"Loading newsletters..."];
    [[NetworkController sharedInstance] getNewslettersWithResponseBlock:^(BOOL success, id response) {
        if (success) {
            self.marketReports = response;
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
                else {
                    [SVProgressHUD showErrorWithStatus:@"Error.\nUser don't have permission to access market reports."];
                    [self.refreshControl endRefreshing];
                    [self.tableView reloadData];
                }
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Error:\nError loading newsletters. Please pull down to refresh."];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                NSLog(@"%@", response);
            }
        }
    }];
}

#pragma mark SetupUiITableViewCell

- (void)setupCell:(MarketReportTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSDictionary *newsletter = [self.marketReports objectAtIndex:indexPath.row];
    NSString *name = [newsletter objectForKey:@"title"];
    [cell.labelNewsLetterName setText:name];
    NSString *date = [newsletter objectForKey:@"date"];
    [cell.labelDate setText:date];
}


#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.marketReports.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Return the Height for cell
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MarketReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMarketReportTableViewCellIdentifier forIndexPath:indexPath];
    [self setupCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *newsletter = [self.marketReports objectAtIndex:indexPath.row];
    //Get url of Pdf and save it to file
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *reportUrl = [newsletter objectForKey:@"file"];

    if (![reportUrl isKindOfClass:[NSNull class]] && reportUrl != nil) {
        NSString* encodedUrl = [reportUrl stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        fullUrl = [NSString stringWithFormat:@"http://borne.io/tpt/%@",encodedUrl];
        NSLog(@"%@", fullUrl);
        NSURL *reportURL = [NSURL URLWithString:fullUrl];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        filePath = [documentsDirectory stringByAppendingPathComponent:@"MyDocument.pdf"];
        
        NSError *error = nil;
        //[self removeFile];
        if ([data writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            [self performSegueWithIdentifier:kMarketReportViewControllerToPDFKBasicPDFViewerSegue sender:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeOrientationToLandscapeNotification object:self];

        } else {
            // error writing file
            NSLog(@"Unable to write PDF to %@. Error: %@", filePath, error);
        }
        [SVProgressHUD dismiss];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Error:\n Unable to load PDF file."];
        return;
    }
}

#pragma Mark - File menagement

- (void)removeFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"deleted.");
    }
    else {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kMarketReportViewControllerToPDFKBasicPDFViewerSegue]) {
        //Create the document for the viewer when the segue is performed.
        PDFKBasicPDFViewer *viewer = (PDFKBasicPDFViewer *)segue.destinationViewController;
        
        
        //Load the document
        PDFKDocument *document = [PDFKDocument documentWithContentsOfFile:filePath password:nil];
        [viewer loadDocument:document];
        [self restrictRotation:NO];
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
