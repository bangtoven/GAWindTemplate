//
//  GAGlobalSetting.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    GAControlModeTouch = 0,
    GAControlModeBlowWithTilt = 1,
    GAControlModeBlowWithOnlyMic = 2,
} GAControlMode;

@interface GASettings : NSObject

//@property (nonatomic, getter=isTouchMode) BOOL touchMode;
@property (nonatomic) GAControlMode controlMode;
@property (nonatomic) float micThreshold;
@property (nonatomic) int keyShift;
@property (nonatomic) BOOL displayNoteName;
@property (nonatomic) float motionSensitivity;
@property (nonatomic) float reverbTime;
@property (nonatomic) float reverbMix;

@property (nonatomic) BOOL hasUpDownOctave;
@property (nonatomic) int baseNote;

+ (instancetype)sharedSetting;
- (void)synchronize;

@end
