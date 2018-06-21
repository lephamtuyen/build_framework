//
//  NotificationManager.h
//  NotificationManager
//
//  Created by Tuyen on 1/8/15.
//  Copyright (c) 2015 Tuyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LANotificationManager;

@protocol LANotificationManagerDelegate <NSObject>

@optional

/*!
 @abstract
 Allow application to handle received notification in active (currently running).
 
 @param application         UIApplication
 @param userInfo            NSDictionary
*/
- (void)handleOpenNotificationFromActive:(UIApplication *)application userInfo:(NSDictionary *)userInfo;

/*!
 @abstract
 Allow application to handle received notification in case
 application is inactive (not running or in background), user receives a push notification, selects the notification and causes the application to launch
 
 @param application         UIApplication
 @param userInfo            NSDictionary
*/
- (void)handleOpenNotificationFromInactive:(UIApplication *)application userInfo:(NSDictionary *)userInfo;

/*!
 @abstract
 Allow custom application to update information received from server.
 
 @param responseObject         Response message from server.
*/
- (void)handleResponseObjectFromServer:(id)responseObject;

@end


@interface LANotificationManager : NSObject

/*!
 @abstract
 Singleton method
*/
+ (LANotificationManager *)sharedNotificationManager;

/*!
 @abstract
 Register remote notification with Apple Push Notification Service (APNS)
 using Amazon Webservice API. This function is called in:
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
 
 of AppDelegate
 @param application         UIApplication.
 @param launchOptions       NSDictionary.
*/
- (void)registerRemoteNotification:(UIApplication *)application withOptions:(NSDictionary *)launchOptions delegate:(id)delegate;

/*!
 @abstract
 After receiving deviceToken from APNS, add this device (user) to your server with given device token.
 This function is called in:
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
 
 of AppDelegate
 @param deviceToken         Device Token received from APNS.
*/
- (void)addUserToServerWithDeviceToken:(NSData *)deviceToken;

/*!
 @abstract
 Handle notification received from server. This function is called in:
 
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
 
 of AppDelegate
 @param application         UIApplication.
 @param launchOptions       NSDictionary.
*/
- (void)didReceiveRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo;

/*! Store client uuid */
@property (nonatomic, strong) NSString *clientId;

@end
