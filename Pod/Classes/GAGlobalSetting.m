//
//  GAGlobalSetting.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import "GAGlobalSetting.h"

@interface GAGlobalSetting ()
{
    BOOL touchMode;
}
@end

@implementation GAGlobalSetting

+ (instancetype)sharedSetting
{
    static GAGlobalSetting *singleton = nil;
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
