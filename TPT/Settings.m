//
//  Settings.m
//  TPT

//  Created by Bosko Barac on 13/10/15.
//  Copyright (c) 2015 Borneagency. All rights reserved.
//

#import "Settings.h"

// NSUserDefaults Keys
static NSString * const kLoginStatusKey = @"LoginStatusKey";
static NSString * const kUserFirstEnteredKey = @"UserFirstEnteredKey";
static NSString * const kPrefferedPositionsKey = @"PrefferedPositionsKey";
static NSString * const kPreferredDefaultKey = @"PreferredDefaultKey";
static NSString * const kShipDocumentationPaths = @"ShipDocumentationPaths";
static NSString * const kInvoicesDoumentationPaths = @"InvoicesDoumentationPaths";

@implementation Settings

// Settings
+ (void)setLoginStatus:(BOOL)status {
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:kLoginStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUserLoggedIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLoginStatusKey];
}

+ (void)DefaultPreferred:(BOOL)preferred {
    [[NSUserDefaults standardUserDefaults] setBool:preferred forKey:kPreferredDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isPreferredDefaul {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kPreferredDefaultKey];
}

+ (void)setUserFirsEnteredApp:(BOOL)entered {
    [[NSUserDefaults standardUserDefaults] setBool:entered forKey:kUserFirstEnteredKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstEnter {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserFirstEnteredKey];
}

+ (void)setSelectedPostionsView:(NSMutableArray *)positionsView {
    [[NSUserDefaults standardUserDefaults] setObject:positionsView forKey:kPrefferedPositionsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)preferredPositions {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPrefferedPositionsKey];
}

+ (void)addShipDocumentationPaths:(NSMutableArray *)shipDocumentationPaths forShip:(NSString *)ship {
    NSMutableArray *shipDocumentationFiles = [[[NSUserDefaults standardUserDefaults] objectForKey:kShipDocumentationPaths] mutableCopy];
    if (shipDocumentationFiles) {
        for (NSDictionary *dict in [shipDocumentationFiles mutableCopy]) {
            if ([dict objectForKey:ship]) {
                [shipDocumentationFiles removeObject:dict];
            }
        }
        
//        if ([shipDocumentationFiles containsObject:ship]) {
//            [shipDocumentationFiles removeObject:ship];
//        }
            [shipDocumentationFiles addObject:@{ship : shipDocumentationPaths}];
    }
    else {
        shipDocumentationFiles = [[NSMutableArray alloc] init];
        [shipDocumentationFiles addObject:@{ship : shipDocumentationPaths}];
    }
    [[NSUserDefaults standardUserDefaults] setObject:shipDocumentationFiles forKey:kShipDocumentationPaths];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)getShipDocumentationPaths {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kShipDocumentationPaths];
}

+ (void)addInvoicesPaths:(NSMutableArray *)invoicesPaths forCharteringId:(NSNumber *)charteringId {
    NSMutableArray *invoicesFiles = [[[NSUserDefaults standardUserDefaults] objectForKey:kInvoicesDoumentationPaths] mutableCopy];
    if (invoicesFiles) {
        for (NSDictionary *dict in [invoicesFiles mutableCopy]) {
            if ([dict objectForKey:charteringId]) {
                [invoicesFiles removeObject:dict];
            }
        }
        
        //        if ([shipDocumentationFiles containsObject:ship]) {
        //            [shipDocumentationFiles removeObject:ship];
        //        }
        [invoicesFiles addObject:@{charteringId : invoicesPaths}];
        
    }
    else {
        invoicesFiles = [[NSMutableArray alloc] init];
        [invoicesFiles addObject:@{charteringId : invoicesPaths}];
    }
    [[NSUserDefaults standardUserDefaults] setObject:invoicesFiles forKey:kInvoicesDoumentationPaths];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)getinvoicesDocumentationPaths {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kInvoicesDoumentationPaths];
}


@end
