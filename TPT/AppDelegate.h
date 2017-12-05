//
//  AppDelegate.h
//  TPT
//
//  Created by Bosko Barac on 12/4/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property () BOOL restrictRotation;
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// Login / Logout
- (void)userLoggedIn;
- (void)userLoggedOut;

@end

