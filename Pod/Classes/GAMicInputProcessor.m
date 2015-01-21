//
//  GABlowProcessor.m
//  asdf
//
//  Created by Jungho Bang on 2014. 11. 14..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAMicInputProcessor.h"
#include <sys/signal.h>

@interface GAMicInputProcessor ()

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic) float lowPassResults;

@end

@implementation GAMicInputProcessor

- (id)init {
    if (self = [super init]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

        NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                                  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                                  nil];
        
        NSError *error;
        
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        
        if (self.recorder) {
            [self.recorder prepareToRecord];
            [self.recorder setMeteringEnabled:YES];
            [self.recorder record];
        } else
            NSLog(@"Error in initializeRecorder: %@", [error description]);
    }
    return self;
}

- (void)startUpdate {
    if (!self.levelTimer)
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}

- (void)stopUpdate {
    if (self.levelTimer) {
        [self.levelTimer invalidate];
        self.levelTimer = nil;
        [self.recorder stop];
    }
}

- (void)levelTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    
//    const double ALPHA = 0.3;
//    double peakPowerForChannel = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
//    self.lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * self.lowPassResults;
    
    double averagePower = pow(10, 0.05 * [self.recorder averagePowerForChannel:0]);
    [self.delegate audioLevelUpdated:averagePower];
}

- (void)dealloc {
    [self stopUpdate];
}

#define MIC_SENSITIVITY_KEY @"mic sensitivity"
+ (float)micSensitivity {
    float sensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:MIC_SENSITIVITY_KEY];
    if (sensitivity < 0.05) {
        sensitivity = 0.5;
        [self setMicSensitivity:sensitivity];
    }
    return sensitivity;
}
+ (void)setMicSensitivity:(float)sensitivity {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:sensitivity forKey:MIC_SENSITIVITY_KEY];
    [defaults synchronize];
}

@end
