//
//  NotificationManager.m
//  NotificationManager
//
//  Created by Tuyen on 1/8/15.
//  Copyright (c) 2015 Tuyen. All rights reserved.
//

#import "LANotificationManager.h"
#import <AFNetworking.h>
#import <AWSSNS.h>
#import <AWSSNSModel.h>
#import "LADefaultSettings.h"
#import <AdSupport/AdSupport.h>

@interface LANotificationManager ()

/*! Store application delegate */
@property (nonatomic, strong) id<LANotificationManagerDelegate>delegate;

@end

@implementation LANotificationManager
@synthesize delegate;

+ (LANotificationManager *)sharedNotificationManager {
    
    static LANotificationManager *sharedNotificationManager = nil;
    
    if (sharedNotificationManager == nil) {
        sharedNotificationManager = [[self alloc] init];
    }
    return sharedNotificationManager;
}

- (void)registerRemoteNotification:(UIApplication *)application withOptions:(NSDictionary *)launchOptions delegate:(id)appDelegate {
    
    // Store delegate
    delegate = appDelegate;
    
    // Load JSON data from file
    [self loadDefaultSettingsJSON];
    
    
    // Amazon Web Service configuration
    AWSStaticCredentialsProvider *credentialProvider = [AWSStaticCredentialsProvider
                                                        credentialsWithAccessKey:@"AKIAJSR37KUQSCWYGNOQ"
                                                        secretKey:@"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"];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration
                                              configurationWithRegion:AWSRegionAPNortheast1
                                              credentialsProvider:credentialProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    // Register apple push notification service (APNS)
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)addUserToServerWithDeviceToken:(NSData *)deviceToken {
    
    const unsigned char *dataBuffer = (const unsigned char *)[deviceToken bytes];
    
    NSUInteger          dataLength  = [deviceToken length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    // uuid to send
    NSString *uuid = @"";
    if ([LADefaultSettings sharedDefaultSettings].uuid != nil) {
        uuid = [LADefaultSettings sharedDefaultSettings].uuid;
    }
    
    // Send advertising Identifier if user allows to advertising tracking.
    NSString *adId = @"";
    if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled == YES) {
        adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    
    // client id to send
    NSString *clientId = @"";
    if (_clientId != nil) {
        clientId = _clientId;
    }
    
    NSDictionary *defaultSettings = [LADefaultSettings sharedDefaultSettings].defaultSettings;
    
    NSDictionary *parameters = @{
                                 @"osInfo": [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]],
                                 @"uuid": uuid,
                                 @"mallUuid": [defaultSettings objectForKey:@"mallUuid"],
                                 @"regId": hexString,
                                 @"adId": adId,
                                 @"clientId": clientId,
                                 @"ver": @"2"
                                 };
    NSLog(@"Request to push.adduser.lkt: %@", parameters);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@", [defaultSettings objectForKey:@"baseUrl"], @"push.adduser.lkt"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response from push.adduser.lkt: %@", responseObject);
        
        // Update uuid
        if (![LADefaultSettings sharedDefaultSettings].uuid) {
            [LADefaultSettings sharedDefaultSettings].uuid = responseObject[@"uuid"];
        }
        
        // Call handler from application
        if ([delegate respondsToSelector:@selector(handleResponseObjectFromServer:)]) {
            [delegate handleResponseObjectFromServer:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
    }];
}

- (void) didReceiveRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo {
    NSLog(@"Handling Remote Notification: %@", userInfo);
    
    // Push log to server with status "open" if application is currently running in foreground
    // OR "application is not running at all, user receives a push notification, selects the notification and causes the application to launch"
    if (application.applicationState == UIApplicationStateActive
        || application.applicationState == UIApplicationStateInactive) {
        [self pushLogToServerWithUserInfo:userInfo status:@"open"];
        
        // Call handler from application.
        if (application.applicationState == UIApplicationStateActive) {
            if ([delegate respondsToSelector:@selector(handleOpenNotificationFromActive:userInfo:)]) {
                [delegate handleOpenNotificationFromActive:application userInfo:userInfo];
            }
        } else {
            if ([delegate respondsToSelector:@selector(handleOpenNotificationFromInactive:userInfo:)]) {
                [delegate handleOpenNotificationFromInactive:application userInfo:userInfo];
            }
        }
    }
    // Push log to server with status "load" if application is currently in background
    // We cannot send log if application is killed
    else {
        [self pushLogToServerWithUserInfo:userInfo status:@"load"];
    }
}

/*!
 @abstract
 Load JSON data from file "style3.def.json" and store in "defaultSettings".
 You can access this variable through:
 
    [LADefaultSettings sharedDefaultSettings].defaultSettings
*/
- (void)loadDefaultSettingsJSON {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"style3.def" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *defaultSettings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"Loading style3.def.json: %@", defaultSettings);
    
    [LADefaultSettings sharedDefaultSettings].defaultSettings = defaultSettings;
}

/*!
 @abstract
 After receiving notification, send a message log to server
 
 @param userInfo        NSDictionary.
 @param status          "open": user opens notification.
                        "load": notification appears on device.
*/
- (void)pushLogToServerWithUserInfo:(NSDictionary *)userInfo status:(NSString *)status {
    // Don't send log if userUuid is empty
    NSString *userUuid = [LADefaultSettings sharedDefaultSettings].uuid;
    if (!userUuid) {
        return;
    }
    
    NSArray *payloadAllKeys = [NSArray arrayWithArray:[userInfo allKeys]];
    
    // pushUuid
    NSString *pushUuid;
    if ([payloadAllKeys containsObject:@"uuid"]) {
        pushUuid = [userInfo valueForKey:@"uuid"];
    }
    [[NSUserDefaults standardUserDefaults] setValue:pushUuid forKey:@"pushUuid"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"pushUuidDatetime"];
    
    // timestamp (long type)
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    // Create message JSON
    NSDictionary *messageDictionary = @{
                                        @"pushUuid": pushUuid,
                                        @"userUuid": userUuid,
                                        @"timestamp": timestamp,
                                        @"status": status
                                        };
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:kNilOptions error:nil];
    NSString *message = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    
    // Push Log to server
    AWSSNSPublishInput *request = [[AWSSNSPublishInput alloc] init];
    [request setTopicArn:@"arn:aws:sns:ap-northeast-1:062310586378:PushShowingQueueiOS"];
    [request setMessage:message];
    
    AWSSNS *sns = [AWSSNS defaultSNS];
    
    [sns publish:request];
    NSLog(@"AWS SNS publish to PushShowingQueueiOS: %@", message);
}
@end
