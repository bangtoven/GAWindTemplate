//
//  GAGlobalSetting.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import "GASettings.h"

@interface GASettings ()
{
    BOOL touchMode;
}
@end

@implementation GASettings

+ (instancetype)sharedSetting
{
    static GASettings *singleton = nil;
    if (!singleton) {
        singleton = [self new];
    }
    return singleton;
}

- (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    touchMode = [defaults boolForKey:@"touch mode"];
}

- (BOOL)isTouchMode
{
    return touchMode;
}

@end
