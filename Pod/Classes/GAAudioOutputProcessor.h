//
//  GAAudioOutputProcessor.h
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAFingeringProcessor.h"
#import "GAMotionProcessor.h"
#import "GAMicInputProcessor.h"

@protocol GAAudioOutputDelegate <NSObject>
- (void)audioOutputStopped;
- (void)audioOutputChangedToNote:(NSString*)note;
- (void)audioOutputChangedWithMicLevel:(float)value;
@end

@interface GAAudioOutputProcessor : NSObject <GAFingeringProcessorDelegate,GAMotionProcessorDelegate>

@property (nonatomic, weak) id<GAAudioOutputDelegate> delegate;
@property (nonatomic, strong) GAFingeringProcessor* fingeringProcessor;

- (void)stopAudioOutput;
- (void)updateSettings;

@end
