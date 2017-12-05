//
//  Utilities.m
//  TPT
//
//  Created by Bosko Barac on 13/10/15.
//  Copyright (c) 2015 Borneagency. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (BOOL)isStringValidEmailAddress:(NSString *)string
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

@end
