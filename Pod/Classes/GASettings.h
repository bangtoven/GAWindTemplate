//
//  GAGlobalSetting.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import <Foundation/Foundation.h>

@interface GASettings : NSObject

@property (nonatomic, getter=isTouchMode) BOOL touchMode;
@property (nonatomic) float micThreshold;
@property (nonatomic) int keyShift;
@property (nonatomic) float motionSensitivity;
@property (nonatomic) float reverbTime;
@property (nonatomic) float reverbMix;

@property (nonatomic) int baseNote;

+ (instancetype)sharedSetting;
- (void)synchronize;

@end
