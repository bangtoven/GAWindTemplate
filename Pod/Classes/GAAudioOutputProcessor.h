//
//  GAAudioOutputProcessor.h
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GAMotionProcessor.h"

@interface GAAudioOutputProcessor : NSObject <GAMotionProcessorDelegate> 

+ (instancetype)sharedOutput;

- (void)setReverbEffectMix:(double)mix;
- (void)setReverbDelay:(double)delay;

- (void)changeNote:(int)note;
- (void)stopPlaying;

@end
