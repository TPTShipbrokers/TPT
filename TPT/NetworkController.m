//
//  NetworkController.m
//  TPT
//
//  Created by Bosko Barac on 10/15/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import "NetworkController.h"
#import "Reachability.h"

static NSString * kTokenErrorMessage = @"An authentication error occurred. Pls, try logging out and in again.";

@interface NetworkController ()
@property (nonatomic) NetworkStatus internetReachabilityStatus;
@property (strong, nonatomic) Reachability *internetReachability;

@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;
@end

@implementation NetworkController

static NSString *host;

+ (NetworkController *)sharedInstance {
    __strong static NetworkController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkController alloc] init];
        
        // Initialize Host
        host = @"http://borne.io/tpt/api/";
        
        // Initialize Network Reachability
        sharedInstance.internetReachability = [Reachability reachabilityForInternetConnection];
        sharedInstance.internetReachabilityStatus = [sharedInstance.internetReachability currentReachabilityStatus];
        [sharedInstance.internetReachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        // Initialize AFSecurityPolicy
        sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [sharedInstance.securityPolicy setAllowInvalidCertificates:YES];
        
        // Initialize AFHTTPRequestOperationManager
        sharedInstance.operationManager = [AFHTTPRequestOperationManager manager];
        [sharedInstance.operationManager setSecurityPolicy:sharedInstance.securityPolicy];
        [sharedInstance.operationManager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    });
    return sharedInstance;
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)notification {
    self.internetReachabilityStatus = [self.internetReachability currentReachabilityStatus];
    if (self.internetReachabilityStatus == ReachableViaWiFi || self.internetReachabilityStatus == ReachableViaWWAN) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshPagesNotification object:self];
    }
}

- (void)alertUserThatInternetIsUnreachableWithBlock:(responseBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block(NO, @"No internet connection.");
    });
}

#pragma mark - Login/Signup Functions

- (void)signInUserWithUsername:(NSString *)username andPassword:(NSString *)password andResponseBlock:(responseBlock)block; {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    NSDictionary *parameters = @{@"username": username,
                                 @"password": password,
                                 @"grant_type": @"password",
                                 @"client_id": @"mobileapp",
                                 @"client_secret": @"mobileappsecret"};
    
    [self.operationManager POST:[NSString stringWithFormat:@"%@oauth2/token", host]
                     parameters:parameters
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            BOOL success = NO;
                            @try {
                                NSDictionary *responseDictionary = responseObject;
                                if ([responseDictionary objectForKey:@"access_token"]) {
                                    [[NSUserDefaults standardUserDefaults] setObject:responseDictionary forKey:@"AccessTokenDictionary"];
//                                    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"UserEmailAddress"];
//                                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"UserPassword"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];

                                    success = YES;
                                }
                            }
                            @catch (NSException *exception) {
                                NSLog(@"Exception in signInUserWithUsername: %@", exception);
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(success, responseObject);
                            });
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error in signInUserWithUsername: %@", error);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                            });
                        }];
}

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken withResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    NSDictionary *parameters = @{@"refresh_token": refreshToken,
                                 @"grant_type": @"refresh_token",
                                 @"client_id": @"mobileapp",
                                 @"client_secret": @"mobileappsecret"};
    
    [self.operationManager POST:[NSString stringWithFormat:@"%@oauth2/token", host]
                     parameters:parameters
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"Refersh: %@", responseObject);
                            BOOL success = NO;
                            @try {
                                NSDictionary *responseDictionary = responseObject;
                                if ([responseDictionary objectForKey:@"access_token"]) {
                                    success = YES;
                                    [[NSUserDefaults standardUserDefaults] setObject:responseDictionary forKey:@"AccessTokenDictionary"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                            }
                            @catch (NSException *exception) {
                                NSLog(@"Exception in refreshAccessTokenWithRefreshToken: %@", exception);
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(success, nil);
                            });
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error in refreshAccessTokenWithRefreshToken: %@", error);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                            });
                        }];
}

- (void)getAccessToken:(responseBlock)block {
    NSDictionary *accessTokenDictioary = [[NSUserDefaults standardUserDefaults] objectForKey:@"AccessTokenDictionary"];
    if (!accessTokenDictioary) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(NO, nil);
        });
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [dateFormatter setLocale:twentyFour];
    
    NSString *accessToken = [[accessTokenDictioary objectForKey:@"access_token"] copy];;
    NSNumber *expiresInSeconds = [accessTokenDictioary objectForKey:@"expires_in"];
    NSString *issuedDateString = [accessTokenDictioary objectForKey:@"issued"];
    NSDate *expirationDate = [[dateFormatter dateFromString:issuedDateString] dateByAddingTimeInterval:(expiresInSeconds.integerValue)];
    
//    NSLog(@"Issued String: %@", issuedDateString);
//    NSLog(@"Issued: %@", [dateFormatter dateFromString:issuedDateString]);
//    NSLog(@"Current: %@", [NSDate date]);
//    NSLog(@"Expires: %@", expirationDate);
    
    NSDate *currentDate = [NSDate date];
    NSString *theDate = [dateFormatter stringFromDate:currentDate];
    NSDate *finalDate = [dateFormatter dateFromString:theDate];
    
    // Refresh and return the Old one
    if(([expirationDate timeIntervalSinceDate:finalDate] < 864) && ([expirationDate timeIntervalSinceDate:finalDate] > 0)) {
        NSString *refreshToken = [accessTokenDictioary objectForKey:@"refresh_token"];
        [self refreshAccessTokenWithRefreshToken:refreshToken withResponseBlock:^(BOOL success, id response) {
            if (success) {
                NSDictionary *newAccessTokenDictioary = [[NSUserDefaults standardUserDefaults] objectForKey:@"AccessTokenDictionary"];
                NSString *newAccessToken = [newAccessTokenDictioary objectForKey:@"access_token"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Working With: %@", newAccessToken);
                    block(YES, newAccessToken);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(NO, response);
                });
            }
        }];
    }
    
    // Re-SignIn and return the new one
    else if ([expirationDate timeIntervalSinceDate:[NSDate date]] <= 0) {
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
        [self signInUserWithUsername:userName andPassword:password andResponseBlock:^(BOOL success, id response) {
            if (success) {
                NSDictionary *newAccessTokenDictioary = [[NSUserDefaults standardUserDefaults] objectForKey:@"AccessTokenDictionary"];
                NSString *newAccessToken = [newAccessTokenDictioary objectForKey:@"access_token"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(YES, newAccessToken);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(NO, response);
                });
            }
        }];
    }
    
    // Return the Old One
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(YES, accessToken);
        });
    }
}


#pragma mark - Contact

- (void)getAllTeamMembersWithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@user/team", host]
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       NSLog(@"ASDASD %@",responseObject);

                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           responseObject = [responseDictionary objectForKey:@"data"];
                                           success = YES;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getAllTeamMembers: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

//Email sending

- (void)sendEmailToUserWithUrl:(NSString *)url files:(NSMutableArray *)files WithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];
            
            NSDictionary *parameters = @{@"email": email,
                                         @"subject": @"TPT forwarded email",
                                         @"body": @"Here is your forwarded data.",
                                         @"files": files};
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager POST:[NSString stringWithFormat:@"%@default/send_email", host]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   
                                   NSDictionary *responseDictionary = responseObject;
                                 
                                   NSNumber *status = [responseDictionary objectForKey:@"status"];
                                   if ([status isEqualToNumber:[NSNumber numberWithInt:200]]) {
                                       success = YES;
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           block(success, responseObject);
                                       });
                                   }
                                   else {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           block(success, responseObject);
                                       });
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

- (void)sendEmailToUserWithText:(NSString *)text fileName:(NSString *)fileName subject:(NSString *)subject WithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmailAddress"];
            NSArray *array = [[NSArray alloc]init];
            
            NSDictionary *parameters = @{@"email": email,
                                         @"subject": subject,
                                         @"body": text,
                                         @"files": array};
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager POST:[NSString stringWithFormat:@"%@default/send_email", host]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    BOOL success = NO;
                                   
                                        NSDictionary *responseDictionary = responseObject;
                                    
                                        NSNumber *status = [responseDictionary objectForKey:@"status"];
                                        if ([status isEqualToNumber:[NSNumber numberWithInt:200]]) {
                                            success = YES;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                block(success, responseObject);
                                            });
                                        }
                                        else {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                block(success, responseObject);
                                            });
                                        }
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                    });
                                }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

- (void)sendEmailToAdminWithText:(NSString *)text fileName:(NSString *)fileName subject:(NSString *)subject WithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            NSString *email = @"chartering@tunept.com";
            
            NSArray *array = [[NSArray alloc]init];
            
            NSDictionary *parameters = @{@"email": email,
                                         @"subject": subject,
                                         @"body": text,
                                         @"files": array};
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager POST:[NSString stringWithFormat:@"%@default/send_email", host]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    BOOL success = NO;
                                    
                                    NSDictionary *responseDictionary = responseObject;
                                    
                                    NSNumber *status = [responseDictionary objectForKey:@"status"];
                                    if ([status isEqualToNumber:[NSNumber numberWithInt:200]]) {
                                        success = YES;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            block(success, responseObject);
                                        });
                                    }
                                    else {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            block(success, responseObject);
                                        });
                                    }
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                    });
                                }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

//User Details

- (void)getUserDetailsWithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@user", host]
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       NSLog(@"ASDASD %@",responseObject);
                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           responseObject = [responseDictionary objectForKey:@"data"];
                                           success = YES;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getUserDetails: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

- (void)changeUserDetailsWithEmail:(NSString *)email password:(NSString *)password status:(NSString *)status WithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            NSDictionary *parameters = @{@"email": email,
                                         @"password": password};
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager PUT:[NSString stringWithFormat:@"%@user", host]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       NSLog(@"ASDASD %@",responseObject);
                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           responseObject = [responseDictionary objectForKey:@"data"];
                                           success = YES;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in changeUserDetails: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

//Push Notifications

- (void)changePushNotificationsSerttingsForSubsDue:(NSNumber *)subsDue outstandingClaims:(NSNumber *)outstandingClaims livePositionUpdates:(NSNumber *)livePositionUpdates WithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            NSDictionary *parameters = @{@"subs_due": subsDue,
                                         @"live_position_updates": livePositionUpdates};
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager PUT:[NSString stringWithFormat:@"%@user/change_notification_settings", host]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   NSLog(@"ASDASD %@",responseObject);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(YES, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

//Positions

- (void)getLivePositionsWithFilters:(NSString *)mrHandy age:(NSNumber *)age sire:(NSString *)sire temaSuitable:(NSString *)temaSuitable locations:(NSMutableArray *)locations condition:(NSString *)condition isAra:(NSNumber *)isAra WithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            NSDictionary *parameters;
            
            if (![condition isEqualToString:@""]) {
                if ([age isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    if (![sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable};
                        }
                    }
                    else if (![sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire};
                        }
                    }
                    else if ([sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"tema_suitable": temaSuitable,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"tema_suitable": temaSuitable};
                        }
                    }
                    else if ([sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {

                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy};
                        }
                    }
                }
                else {
                    if (![sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age};
                        }
                    }
                    else if (![sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"sire": sire,
                                           @"age" : age};
                        }
                    }
                    else if ([sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age};
                        }
                    }
                    else if ([sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"grade": condition,
                                           @"size": mrHandy,
                                           @"age" : age};
                        }
                    }
                }
            }
            else {
                if ([age isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    if (![sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {

                            parameters = @{@"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable};
                        }
                    }
                    else if (![sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {
                            parameters = @{@"size": mrHandy,
                                           @"sire": sire,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"size": mrHandy,
                                           @"sire": sire};
                        }
                    }
                    else if ([sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {
                            parameters = @{@"size": mrHandy,
                                           @"tema_suitable": temaSuitable,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"size": mrHandy,
                                           @"tema_suitable": temaSuitable};
                        }
                    }
                    else if ([sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {
                            parameters = @{@"size": mrHandy,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"size": mrHandy};
                        }
                    }
                }
                else {
                    if (![sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {
                            parameters = @{@"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"size": mrHandy,
                                           @"sire": sire,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age};
                        }
                    }
                    else if (![sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {
                            parameters = @{@"size": mrHandy,
                                           @"sire": sire,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            
                            parameters = @{@"size": mrHandy,
                                           @"sire": sire,
                                           @"age" : age};
                        }
                    }
                    else if ([sire isEqualToString:@""] && ![temaSuitable isEqualToString:@""]) {
                        
                        if (locations.count > 0) {
                            parameters = @{@"size": mrHandy,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"size": mrHandy,
                                           @"tema_suitable": temaSuitable,
                                           @"age" : age};
                        }
                    }
                    else if ([sire isEqualToString:@""] && [temaSuitable isEqualToString:@""]) {
                        if (locations.count > 0) {
                            parameters = @{@"size": mrHandy,
                                           @"age" : age,
                                           @"location": locations};
                        }
                        else {
                            parameters = @{@"size": mrHandy,
                                           @"age" : age};
                        }
                    }
                }
            }

            NSString *url;
            if (isAra == [NSNumber numberWithBool:true]) {
                url = @"ara-positions";
            }
            else {
                url = @"waf-positions";
            }
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@%@/all/", host, url]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           responseObject = [responseDictionary objectForKey:@"data"];
                                           success = YES;
                                       }
                                       else {
                                           success = NO;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getLivePositions: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

- (void)getPositionsLocationsWithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@vessels/locations", host]
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           responseObject = [responseDictionary objectForKey:@"data"];
                                           success = YES;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getUserDetails: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

//Chartering

- (void)getCharteringListWithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@chartering", host]
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       
                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           responseObject = [responseDictionary objectForKey:@"data"];
                                           success = YES;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getCharteringList: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

- (void)getCharteringDetailsForCharterId:(NSString *)charterId WithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@chartering/%@", host, charterId]
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       
                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           success = YES;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getCharteringList: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

//Post Chartering
- (void)getPostCharteringListWithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@chartering/post", host]
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       NSLog(@"ASDASD %@",responseObject);
                                       
                                       NSDictionary *responseDictionary = responseObject;
                                       if ([responseDictionary objectForKey:@"data"]) {
                                           responseObject = [responseDictionary objectForKey:@"data"];
                                           success = YES;
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getCharteringList: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}

//Newsletters

- (void)getNewslettersWithResponseBlock:(responseBlock)block {
    if (self.internetReachabilityStatus == NotReachable) {
        [self alertUserThatInternetIsUnreachableWithBlock:block];
        return;
    }
    
    __block NSString *accessToken = @"";
    [self getAccessToken:^(BOOL success, id response) {
        if (success) {
            accessToken = response;
            
            [self.operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self.operationManager GET:[NSString stringWithFormat:@"%@market_reports", host]
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   BOOL success = NO;
                                   @try {
                                       NSString *result = [responseObject objectForKey:@"result"];
                                       if ([result isEqualToString:@"error"]) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               block(NO, @"User don't have permission to access market reports.");
                                           });
                                       }
                                       else {
                                           NSDictionary *responseDictionary = responseObject;
                                           if ([responseDictionary objectForKey:@"data"]) {
                                               responseObject = [responseDictionary objectForKey:@"data"];
                                               
                                               success = YES;
                                           }
                                       }
                                                                          }
                                   @catch (NSException *exception) {
                                       responseObject = @"Exception";
                                       NSLog(@"Exception in getUserDetails: %@", exception);
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(success, responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       block(NO, (error.code == NSURLErrorTimedOut) ? @"The request timed out." : error);
                                   });
                               }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, kTokenErrorMessage);
            });
        }
    }];
}


@end
