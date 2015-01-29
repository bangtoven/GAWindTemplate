//
//  GAMotionProcessor.m
//  Hun
//
//  Created by Jungho Bang on 2014. 11. 6..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAMotionProcessor.h"

@interface GAMotionProcessor ()
@property (strong) CMMotionManager *motionManager;
@end

@implementation GAMotionProcessor

-(void)startUpdate {
    if (self.motionManager)
        return;
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    if (self.motionManager.isDeviceMotionAvailable) {
        NSOperationQueue *gyroQueue = [[NSOperationQueue alloc] init];
        self.motionManager.deviceMotionUpdateInterval = 1 / 100.0;
        [self.motionManager startDeviceMotionUpdatesToQueue:gyroQueue withHandler:
         ^(CMDeviceMotion *motion, NSError *error) {
             [self performSelectorOnMainThread: @selector(update:)
                                    withObject: motion
                                 waitUntilDone: YES];
         }];
    }
}

- (void)update:(CMDeviceMotion*)motion {
    [self.delegate motionUpdated:motion];
}

-(void)stopUpdate {
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

@end
