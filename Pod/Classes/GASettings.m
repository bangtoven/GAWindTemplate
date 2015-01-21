//
//  GAGlobalSetting.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import "GASettings.h"

@implementation GASettings
@synthesize isTouchMode;
@synthesize keyShift;

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
    isTouchMode = [defaults boolForKey:@"touch mode"];
    keyShift = (int)[defaults integerForKey:@"key shift"];
}

- (BOOL)isTouchMode
{
    return isTouchMode;
}

- (int)keyShift
{
    return keyShift;
}

@end
