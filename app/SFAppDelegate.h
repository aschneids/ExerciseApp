//
//  SFAppDelegate.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//  Copyright (c) 2013 Lunde. All rights reserved.
//


@class SFAppDelegate;

@interface SFAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

+ (BOOL)isLiteVersion;

@end
