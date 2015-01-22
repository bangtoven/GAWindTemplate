//
//  GAGlobalSetting.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import "GASettings.h"
#import "NSBundle+GATemplate.h"

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
        NSURL *url = [[NSBundle templateBundle] URLForResource:@"GADefaultSettings" withExtension:@"plist"];
        NSDictionary *initialDefaults = [NSDictionary dictionaryWithContentsOfURL:url];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:initialDefaults];
        
        _touchMode = [defaults boolForKey:@"_touchMode"];
        _micThreshold = [defaults floatForKey:@"_micThreshold"];
        _keyShift = (int)[defaults integerForKey:@"_keyShift"];
        _motionSensitivity = [defaults floatForKey:@"_motionSensitivity"];
        _reverbTime = [defaults floatForKey:@"_reverbTime"];
        _reverbMix = [defaults floatForKey:@"_reverbMix"];
    }
    return self;
}

- (void)synchronize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_touchMode forKey:@"_touchMode"];
    [defaults setFloat:_micThreshold forKey:@"_micThreshold"];
    [defaults setInteger:_keyShift forKey:@"_keyShift"];
    [defaults setFloat:_motionSensitivity forKey:@"_motionSensitivity"];
    [defaults setFloat:_reverbTime forKey:@"_reverbTime"];
    [defaults setFloat:_reverbMix forKey:@"_reverbMix"];
    [defaults synchronize];
}

@end
