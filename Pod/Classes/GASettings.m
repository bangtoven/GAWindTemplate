//
//  GAGlobalSetting.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import "GASettings.h"

@implementation GASettings

+ (instancetype)sharedSetting
{
    static GASettings *singleton = nil;
    if (!singleton) {
        singleton = [[self alloc] init];
    }
    return singleton;
}

- (id)init
{
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults boolForKey:@"initialized"]==NO) {
            _touchMode = NO;
            _micSensitivity = 0.5;
            _keyShift = 0;
            _reverbTime = 1.8;
            _reverbMix = 0.25;
            [defaults setBool:YES forKey:@"initialized"];
            [self synchronize];
        }
        else {
            _touchMode = [defaults boolForKey:@"touch mode"];
            _micSensitivity = [defaults floatForKey:@"mic sensitivity"];
            _keyShift = (int)[defaults integerForKey:@"key shift"];
            _reverbTime = [defaults floatForKey:@"reverb time"];
            _reverbMix = [defaults floatForKey:@"reverb mix"];
        }
    }
    return self;
}

- (void)synchronize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_touchMode forKey:@"touch mode"];
    [defaults setFloat:_micSensitivity forKey:@"mic sensitivity"];
    [defaults setInteger:_keyShift forKey:@"key shift"];
    [defaults setFloat:_reverbTime forKey:@"reverb time"];
    [defaults setFloat:_reverbMix forKey:@"reverb mix"];
    [defaults synchronize];
}

@end
