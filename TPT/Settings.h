//
//  Settings.h
//  TPT
//
//  Created by Bosko Barac on 13/10/15.
//  Copyright (c) 2015 Borneagency. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Settings : NSObject

// Settings
+ (void)setLoginStatus:(BOOL)status;
+ (BOOL)isUserLoggedIn;
+ (void)setUserFirsEnteredApp:(BOOL)entered;
+ (BOOL)isFirstEnter;
+ (void)setSelectedPostionsView:(NSMutableArray *)positionsView;
+ (NSArray *)preferredPositions;
+ (void)DefaultPreferred:(BOOL)preferred;
+ (BOOL)isPreferredDefaul;

+ (void)addShipDocumentationPaths:(NSMutableArray *)shipDocumentationPaths forShip:(NSString *)ship;
+ (NSArray *)getShipDocumentationPaths;

+ (void)addInvoicesPaths:(NSMutableArray *)invoicesPaths forCharteringId:(NSNumber *)charteringId;
+ (NSArray *)getinvoicesDocumentationPaths;
@end
