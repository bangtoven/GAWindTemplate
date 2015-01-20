//
//  GAAudioOutputProcessor.h
//  Pods
//
//  Created by bangtoven on 2015. 1. 14..
//
//

#import <Foundation/Foundation.h>

@interface GAAudioOutputProcessor : NSObject

- (instancetype)initWithAudioInputTable:(NSArray*)dictArray;

- (void)stopPlaying;

- (void)changeNote:(int)note;
- (void)changePitch:(double)pitch;
- (void)changeGain:(double)gain;

- (void)setMasterVolume:(double)volume;

@end
