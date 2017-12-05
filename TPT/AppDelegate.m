//
//  AppDelegate.m
//  TPT
//
//  Created by Bosko Barac on 12/4/15.
//  Copyright © 2015 Borne Agency. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkController.h"
#import "TestFairy.h"
#import <OneSignal/OneSignal.h>
@import Firebase;


@interface AppDelegate ()
@property (strong, nonatomic) UINavigationController *loginNavController;
@property (strong, nonatomic) UIViewController *mainViewController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Start Analytics
    
    [FIRApp configure];
    
    [TestFairy begin:@"52a9fd5991661ee0bc86175b7238b8d7eae3cbff"];
    
    //OneSignal setup
    //[OneSignal initWithLaunchOptions:launchOptions appId:@"110b54af-45f3-4fa7-8e79-9fb726ad263c"];
    
    // Set Navigation and BarButton bar appearance
    [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];

    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Avenir-Heavy" size:16], NSFontAttributeName, nil]];
    NSDictionary *barButtonTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIColor whiteColor],
                                                  NSForegroundColorAttributeName,
                                                  [UIFont fontWithName:@"Avenir-Heavy" size:17],
                                                  NSFontAttributeName,
                                                  nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleTextAttributes forState:UIControlStateNormal];
    
    // Parse Setup
    [Parse setApplicationId:@"oZMGHWT4yPLp5kDpOMMsbmvPOBrH54rDYuJrC39m"
                  clientKey:@"fgG46JAzg0Pb9IIzJBTZiV5BMe3eS381z5adYtMK"];
    [[PFInstallation currentInstallation] saveInBackground];
    
    //Register for remote notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    // Check for Login
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kMainStoryboard bundle:nil];
    self.loginNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kLoginNavViewController];
    self.mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:krootController];
    if ([Settings isUserLoggedIn]) {
        self.window.rootViewController = self.mainViewController;
    }
    else {
        self.window.rootViewController = self.loginNavController;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"SelectedLocation"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"CleanDirtyFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"NumberSelectedFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"SireFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"TemaSuitableFilter"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FilterActive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if(self.restrictRotation) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FilterActive"];
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"SelectedLocation"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LocationIsSelected"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // Call registerForRemoteNotifications on iOS 8
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
//    UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"TPT"    message:@"SUBS DUE"
//                                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    
//    [notificationAlert show];
    // NSLog(@"didReceiveLocalNotification");
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.borneagency.TPT" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TPT" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TPT.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Private

- (void)userLoggedIn {
    // Remove Login Screen when user logs in
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kMainStoryboard bundle:nil];
    self.mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:krootController];
    
    [self.window insertSubview:self.mainViewController.view belowSubview:self.window.rootViewController.view];
    [UIView transitionWithView:self.window.rootViewController.view
                      duration:0.25
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        self.window.rootViewController.view.frame = CGRectMake(0, self.window.rootViewController.view.frame.size.height, self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height);
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                    completion:^(BOOL finished){
                        self.window.rootViewController = self.mainViewController;
                    }];
}

- (void)userLoggedOut {
    // Present Login screen when user logs out
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kMainStoryboard bundle:nil];
    self.loginNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kLoginNavViewController];
    UINavigationController *navcon = (UINavigationController *)self.window.rootViewController;
    [navcon presentViewController:self.loginNavController animated:YES completion:nil];
}

@end
