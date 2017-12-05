//
//  NetworkController.h
//  TPT
//
//  Created by Bosko Barac on 10/15/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^responseBlock)(BOOL success, id response);

@interface NetworkController : NSObject

+ (NetworkController *)sharedInstance;
- (void)getAccessToken:(responseBlock)block;

// SignUp Login
- (void)signInUserWithUsername:(NSString *)username andPassword:(NSString *)password andResponseBlock:(responseBlock)block;

//Contact
- (void)getAllTeamMembersWithResponseBlock:(responseBlock)block;
- (void)sendEmailToUserWithUrl:(NSString *)url files:(NSMutableArray *)files WithResponseBlock:(responseBlock)block;
- (void)sendEmailToUserWithText:(NSString *)text fileName:(NSString *)fileName subject:(NSString *)subject WithResponseBlock:(responseBlock)block;
- (void)sendEmailToAdminWithText:(NSString *)text fileName:(NSString *)fileName subject:(NSString *)subject WithResponseBlock:(responseBlock)block;
//User Details
- (void)getUserDetailsWithResponseBlock:(responseBlock)block;
- (void)changeUserDetailsWithEmail:(NSString *)email password:(NSString *)password status:(NSString *)status WithResponseBlock:(responseBlock)block;

//Push Notifications
- (void)changePushNotificationsSerttingsForSubsDue:(NSNumber *)subsDue outstandingClaims:(NSNumber *)outstandingClaims livePositionUpdates:(NSNumber *)livePositionUpdates WithResponseBlock:(responseBlock)block;

//Live Positions
- (void)getLivePositionsWithFilters:(NSString *)mrHandy age:(NSNumber *)age sire:(NSString *)sire temaSuitable:(NSString *)temaSuitable locations:(NSMutableArray *)locations condition:(NSString *)condition isAra:(NSNumber *)isAra WithResponseBlock:(responseBlock)block;
- (void)getPositionsLocationsWithResponseBlock:(responseBlock)block;

//Chartering
- (void)getCharteringListWithResponseBlock:(responseBlock)block;
- (void)getCharteringDetailsForCharterId:(NSString *)charterId WithResponseBlock:(responseBlock)block;

//Post Chartering
- (void)getPostCharteringListWithResponseBlock:(responseBlock)block;

//Market Reports
- (void)getNewslettersWithResponseBlock:(responseBlock)block;
@end
