//
//  AppDelegate.m
//  TestFramework
//
//  Created by Tuyen on 1/12/15.
//  Copyright (c) 2015 Tuyen. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _viewController = [[ViewController alloc] init];
    
    _window.rootViewController = _viewController;
    [_window makeKeyAndVisible];
    
    [[LANotificationManager sharedNotificationManager] registerRemoteNotification:application withOptions:launchOptions delegate:self];
    [LANotificationManager sharedNotificationManager].clientId = @"Hello";
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[LANotificationManager sharedNotificationManager] addUserToServerWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [[LANotificationManager sharedNotificationManager] didReceiveRemoteNotification:application userInfo:userInfo];
    
    //Tell the system that you're done.
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - LANotificationManagerDelegate implementation

- (void)handleOpenNotificationFromActive:(UIApplication *)application userInfo:(NSDictionary *)userInfo {
    NSString *msg = [[[userInfo valueForKey:@"aps"] objectForKey:@"alert"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (msg != nil) {
        NSDictionary *defaultSettings = [LADefaultSettings sharedDefaultSettings].defaultSettings;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[defaultSettings objectForKey:@"mallName"] message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView setTag:0];
        [alertView show];
    }
}

- (void)handleOpenNotificationFromInactive:(UIApplication *)application userInfo:(NSDictionary *)userInfo {
    NSString *msg = [[[userInfo valueForKey:@"aps"] objectForKey:@"alert"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (msg != nil) {
        NSDictionary *defaultSettings = [LADefaultSettings sharedDefaultSettings].defaultSettings;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[defaultSettings objectForKey:@"mallName"] message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView setTag:0];
        [alertView show];
    }
}

- (void)handleResponseObjectFromServer:(id)responseObject {
    
}

@end
