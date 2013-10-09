//
//  SFAppDelegate.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//  Copyright (c) 2013 Lunde. All rights reserved.
//

#import <Parse/Parse.h>
#import "SFAppDelegate.h"
#import "SFHomeViewController.h"
#import "SFVideoListViewController.h"

@implementation SFAppDelegate

@synthesize window;
@synthesize tabBarController;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse setApplicationId:@"P3ssFWkmlU5DxbGldkDq6kYEHDy7JmA0KYoaqU2e" clientKey:@"kybJSNngeWOxr3Tfq4yRb7lqfifcw5svQzYG7fGf"];

    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];

    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                    UIRemoteNotificationTypeAlert|
                                                    UIRemoteNotificationTypeSound];
    
    self.tabBarController = [[UITabBarController alloc] init];
    UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    SFHomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Home"];
    homeViewController.tabBarItem.image = [UIImage imageNamed:@"home.png"];
    homeViewController.title = @"Home";
    
    SFVideoListViewController *fieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoList"];
    fieldViewController.tabBarItem.image = [UIImage imageNamed:@"field.png"];
    fieldViewController.title = @"Field";
    UINavigationController *fieldNavController = [[UINavigationController alloc] initWithRootViewController:fieldViewController];
    fieldNavController.navigationBarHidden = YES;
    
    SFVideoListViewController *officeViewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoList"];
    officeViewController.tabBarItem.image = [UIImage imageNamed:@"office.png"];
    officeViewController.title = @"Office";
    UINavigationController *officeNavController = [[UINavigationController alloc] initWithRootViewController:officeViewController];
    officeNavController.navigationBarHidden = YES;
    
    SFVideoListViewController *targetViewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoList"];
    targetViewController.tabBarItem.image = [UIImage imageNamed:@"target.png"];
    targetViewController.title = @"Target Areas";
    UINavigationController *targetNavController = [[UINavigationController alloc] initWithRootViewController:targetViewController];
    targetNavController.navigationBarHidden = YES;

    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeViewController, fieldNavController, officeNavController, targetNavController, nil];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = self.tabBarController;
    
    // need this last line to display the window (and tab bar controller)
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];

    if (application.applicationState != UIApplicationStateActive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}


@end
