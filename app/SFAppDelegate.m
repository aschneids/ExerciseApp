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
    homeViewController.title = @"About";
    UIImage *selectedImage4 = [[UIImage imageNamed:@"info-active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeViewController.tabBarItem.selectedImage = selectedImage4;
    homeViewController.tabBarItem.image = [UIImage imageNamed:@"info.png"];
    [homeViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                                            nil] forState:UIControlStateSelected];

    
    SFVideoListViewController *fieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoList"];
    fieldViewController.tabBarItem.title = @"Field";
    UIImage *selectedImage = [[UIImage imageNamed:@"sun-active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fieldViewController.tabBarItem.selectedImage = selectedImage;
    fieldViewController.tabBarItem.image = [UIImage imageNamed:@"sun.png"];
    [fieldViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor], NSForegroundColorAttributeName,
                                               nil] forState:UIControlStateSelected];
    
    SFVideoListViewController *officeViewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoList"];
    officeViewController.title = @"Office";
    UIImage *selectedImage2 = [[UIImage imageNamed:@"lamp-active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    officeViewController.tabBarItem.selectedImage = selectedImage2;
    officeViewController.tabBarItem.image = [UIImage imageNamed:@"lamp.png"];
    [officeViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                                            nil] forState:UIControlStateSelected];
    
    SFVideoListViewController *targetViewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoList"];
    targetViewController.title = @"Target Areas";
    UIImage *selectedImage3 = [[UIImage imageNamed:@"target-active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    targetViewController.tabBarItem.selectedImage = selectedImage3;
    targetViewController.tabBarItem.image = [UIImage imageNamed:@"target.png"];
    [targetViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                                            nil] forState:UIControlStateSelected];

    self.tabBarController.viewControllers = [NSArray arrayWithObjects:fieldViewController, officeViewController, targetViewController, homeViewController, nil];
    
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

#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}


@end
