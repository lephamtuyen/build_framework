//
//  AppDelegate.h
//  TestFramework
//
//  Created by Tuyen on 1/12/15.
//  Copyright (c) 2015 Tuyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <LooketAppsSDK/LANotificationManager.h>
#import <LooketAppsSDK/LADefaultSettings.h>
//#import "LADefaultSettings.h"
//#import "LANotificationManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, LANotificationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

@end

