//
//  LADefaultSettings.m
//  LooketAppsSDK
//
//  Created by Tuyen on 1/8/15.
//  Copyright (c) 2015 Tuyen. All rights reserved.
//

#import "LADefaultSettings.h"

@implementation LADefaultSettings

+ (LADefaultSettings *)sharedDefaultSettings {
    static LADefaultSettings *sharedDefaultSettings = nil;
    if (sharedDefaultSettings == nil) {
        sharedDefaultSettings = [[LADefaultSettings alloc] init];
    }
    
    return sharedDefaultSettings;
}

- (NSString *)uuid {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
}


- (void)setUuid:(NSString *)uuid {
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"uuid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)defaultSettings {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"defaultSettings"];
}

- (void)setDefaultSettings:(NSDictionary *)defaultSettings {
    [[NSUserDefaults standardUserDefaults] setObject:defaultSettings forKey:@"defaultSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
