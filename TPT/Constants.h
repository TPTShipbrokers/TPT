//
//  Constants.h
//  TPT
//
//  Created by Bosko Barac on 13/10/15.
//  Copyright (c) 2015 Borneagency. All rights reserved.
//

#define DEVICE_SIZE [[[[UIApplication sharedApplication] keyWindow] rootViewController].view convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

#define iPhone6 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width) == 667)
#define iPhone6Plus ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width) == 736)
#define iphone5 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width) == 568)

#import <UIKit/UIKit.h>

// Constants
extern NSString * const kChangeOrientationToLandscapeNotification;
extern NSString * const kChangeOrientationToPortraitNotification;
extern NSString * const kRefreshPagesNotification;
extern NSString * const kFilterActiveNotification;


// Storyboards
extern NSString * const kMainStoryboard;

// ViewController Identifiers
extern NSString * const kLoginNavViewController;
extern NSString * const kOngoingOperationsNavViewController;
extern NSString * const kMenuViewController;
extern NSString * const kSettingsNavViewController;
extern NSString * const krootController;
extern NSString * const kMarketReportNavViewController;
extern NSString * const kPositionsListNavViewController;
extern NSString * const kCharteringListNavViewController;
extern NSString * const kPostTransactionalNavViewController;
extern NSString * const kContactNavViewController;
extern NSString * const kShipDocumentationViewController;
extern NSString * const kFilterNavViewController;

// Segue Identifiers

extern NSString * const kPositionsListViewControllerToEmailEnquiryViewControllerSegue;
extern NSString * const kCharteringListViewControllerToStatemantOFFactsViewControllerSegue;
extern NSString * const kCharteringListViewControllerToCharterPartyViewControllerSegue;
extern NSString * const kPostTransactionalViewControllerToCharterPartyViewControllerSegue;
extern NSString * const kPostTransactionalViewControllerToStatemantOFFactsViewControllerSegue;
extern NSString * const kPostTransactionalViewControllerToOutstandingClaimsViewControllerSegue;
extern NSString * const kPostTransactionalViewControllerToInvoiceViewControllerSegue;
extern NSString * const kSettingsViewControllerToPushNotificationsViewControllerSegue;
extern NSString * const kSettingsViewControllerToPasswordViewControllerSegue;
extern NSString * const kSettingsViewControllerToPositionsSettingsViewControllerSegue;
extern NSString * const kCharteringListViewControllerToEmailEnquiryViewControllerSegue;
extern NSString * const kPostTransactionalViewControllerToEmailEnquiryViewControllerSegue;
extern NSString * const kCharteringListViewControllerToPDFKBasicPDFViewerSegue;
extern NSString * const kOutstandingClaimsViewControllerToPDFKBasicPDFViewerSegue;
extern NSString * const kMarketReportViewControllerToPDFKBasicPDFViewerSegue;
extern NSString * const kCharteringListViewControllerToShipDocumentationViewControllerSegue;
extern NSString * const kShipDocumentationViewControllerToPDFKBasicPDFViewerSegue;
extern NSString * const kInvoiceViewControllerToPDFKBasicPDFViewerSegue;
extern NSString * const kOutstandingClaimsViewControllerToEmailEnquiryViewControllerSegue;
extern NSString * const kCharteringListViewControllerToInvoiceViewControllerSegue;
extern NSString * const kFilterViewControllerToLocationsViewControllerSegue;

// Cell / Item Identifiers

extern NSString * const kPositionsTableViewCellIdentifier;
extern NSString * const kCharteringTableViewCellIdentifier;
extern NSString * const kPostTransactionTableViewCellIdentifier;
extern NSString * const kInvoiceTableViewCellIdentifier;
extern NSString * const kPushNotificationsTableViewCellIdentifier;
extern NSString * const kContactListTableViewCellIdentifier;
extern NSString * const kEmailEnquiryTableViewCellIdentifier;
extern NSString * const kMarketReportTableViewCellIdentifier;
extern NSString * const kShipDocumentationTableViewCellIdentifier;
extern NSString * const kLocationsTableViewCellIdentifier;







