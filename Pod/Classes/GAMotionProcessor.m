//
//  GAMotionProcessor.m
//  Hun
//
//  Created by Jungho Bang on 2014. 11. 6..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAMotionProcessor.h"

@interface GAMotionProcessor () {
    CMMotionManager *motionManager;
}
@end

@implementation GAMotionProcessor

+ (GAMotionProcessor*)motionProcessor {
    static GAMotionProcessor *singleton;
    if (!singleton) {
        singleton = [[GAMotionProcessor alloc] init];
    }
    return singleton;
}

-(void)startUpdate {
    if (motionManager) 
        return;
    
    motionManager = [[CMMotionManager alloc] init];
    
    double calibrationTime = 0.01;
    
    if (motionManager.isDeviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 1 / 100.0;
        __block NSTimeInterval lastTimeStamp = -1.0;
        __block double lastAttitude = -1;
        NSOperationQueue *gyroQueue = [[NSOperationQueue alloc] init];
        [motionManager startDeviceMotionUpdatesToQueue:gyroQueue withHandler:
         ^(CMDeviceMotion *motion, NSError *error) {
             if (lastTimeStamp < 0) {
                 lastTimeStamp = motion.timestamp;
             }
             
             if (motion.timestamp - lastTimeStamp > calibrationTime) {
//                 double pitch = motion.attitude.pitch;
                 double pitch = motion.userAcceleration.y;
                 double diff = pitch-lastAttitude;
                 if (ABS(diff)>0.005) {
                     [self performSelectorOnMainThread: @selector(update:)
                                            withObject: [NSNumber numberWithDouble:pitch]
                                         waitUntilDone: NO];
                     lastAttitude = pitch;
                 }
                 lastTimeStamp = motion.timestamp;
             }
         }];
    }
}

- (void)update:(NSNumber*)input {
//    double intensity = input.doubleValue + M_PI_2;
//    if (intensity < 0) intensity = 0;
//
//    double angle = intensity/M_PI*180.0;
//    
//    [self.delegate motionUpdatedToAngle:angle];
    [self.delegate motionUpdatedToAngle:input.doubleValue];
}

-(void)stopUpdate {
    [motionManager stopDeviceMotionUpdates];
    motionManager = nil;
}

@end
