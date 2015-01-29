//
//  GABlowProcessor.m
//  asdf
//
//  Created by Jungho Bang on 2014. 11. 14..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAMicInputProcessor.h"
#import "GASettings.h"
#include <sys/signal.h>

#define MIC_UPDATE_INTERVAL 0.01
#define IDLE_TIME_THRESHOLD 5

@interface GAMicInputProcessor () {
    BOOL processThreshold;
    float micThreshold;
    int idleTime;
}

@property (nonatomic, weak) id <GAMicInputProcessorDelegate> delegate;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic) float lowPassResults;

@end

@implementation GAMicInputProcessor

- (id)initWithDelegate:(id<GAMicInputProcessorDelegate>)delegate andProcessThreshold:(BOOL)process {
    if (self = [super init]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                                  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                                  nil];
        
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        
        if (self.recorder && error==nil) {
            [self.recorder prepareToRecord];
            [self.recorder setMeteringEnabled:YES];
        } else
            NSLog(@"Error in initializeRecorder: %@", [error description]);
        
        [self updateSettings];
        self.delegate = delegate;
        processThreshold = process;
    }
    return self;
}

- (void)updateSettings
{
    GASettings *settings = [GASettings sharedSetting];
    micThreshold = settings.micThreshold;
    idleTime = 0;
}

- (void)startUpdate {
    if (!self.levelTimer) {
        if (processThreshold)
            self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:MIC_UPDATE_INTERVAL target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        else
            self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:MIC_UPDATE_INTERVAL target: self selector: @selector(rawLevelTimerCallback:) userInfo: nil repeats: YES];
    }
    
    if (self.recorder.isRecording == NO)
        [self.recorder record];
}

- (void)stopUpdate {
    if (self.levelTimer) {
        [self.levelTimer invalidate];
        self.levelTimer = nil;
    }
    
    if (self.recorder.isRecording)
        [self.recorder stop];
}

- (void)rawLevelTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    double averagePower = pow(10, 0.05 * [self.recorder averagePowerForChannel:0]);
    [self.delegate micInputLevelUpdated:averagePower];
}

- (void)levelTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    double averagePower = pow(10, 0.05 * [self.recorder averagePowerForChannel:0]);
    
    if (averagePower > micThreshold) {
        if (idleTime >= IDLE_TIME_THRESHOLD)
            [self.delegate micInputStarted];
        
        idleTime = 0;
        [self.delegate micInputLevelUpdated:averagePower];
    }
    else {
        if (idleTime < IDLE_TIME_THRESHOLD) {
            idleTime++;
            [self.delegate micInputLevelUpdated:averagePower];
        }
        else if (idleTime == IDLE_TIME_THRESHOLD) {
            idleTime = INT32_MAX;
            [self.delegate micInputStopped];
        }
    }
}

- (void)dealloc {
    [self stopUpdate];
}

@end
