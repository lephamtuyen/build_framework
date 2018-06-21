//
//  LADefaultSettings.h
//  LooketAppsSDK
//
//  Created by Tuyen on 1/8/15.
//  Copyright (c) 2015 Tuyen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LADefaultSettings : NSObject

/*!
 @abstract
 Singleton method
*/
+ (LADefaultSettings *)sharedDefaultSettings;

/*! Store user identifer */
@property (strong) NSString *uuid;

/*! Store default setting (website, name, hallId, ...) */
@property (strong) NSDictionary *defaultSettings;

@end
