//
//  GAAudioOutputProcessor.m
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import "GAAudioOutputProcessor.h"

#import "AEAudioController.h"
#import "AEBlockChannel.h"
#import "NRev.h"

#import "GAAudioInputFile.h"
#import "GAAudioInputTable.h"

#import "GASettings.h"

@interface GAAudioOutputProcessor () <GAMicInputProcessorDelegate> {
    stk::NRev reverb;

    float motionSensitivity;
    double lastAccel;
}

@property (nonatomic, strong) GAMotionProcessor *motionProcessor;
@property (nonatomic, strong) GAMicInputProcessor *micProcessor;

@property (nonatomic, strong) GAAudioInputTable *audioInputTable;
@property (strong) AEAudioController *audioController;
@property (strong) NSMutableArray *audioOutput;

@end

@implementation GAAudioOutputProcessor

- (void)fingeringChangedWithNote:(int)note
{
    if (note == FINGERING_ALL_OPEN)
        [self stopPlaying];
    else {
        GAAudioInputFile *input = [self.audioInputTable audioInputOfNote:note];
        [self.audioOutput insertObject:input atIndex:0];
        [self.delegate audioOutputChangedToNote:input.noteName];
    }
}

- (void)motionUpdated:(CMDeviceMotion *)motion {
    if (self.audioOutput.count == 0)
        return;
    
    double accelY = motion.userAcceleration.y;
    double diff = accelY-lastAccel;
    
    if (ABS(diff)>0.005) {
        double adjusted = accelY*motionSensitivity;
        double pitch = erf(adjusted)*2;
        double rate = pow(1.0594, pitch);
        GAAudioInputFile *afi = self.audioOutput[0];
        [afi setRate:rate];
        
        double factor = 0.4 * motionSensitivity/0.6;
        double volume = erf(accelY)*factor + 0.6;
        AEBlockChannel *myBlockChannel = self.audioController.channels.lastObject;
        myBlockChannel.volume = volume;

        lastAccel = accelY;
    }
}

- (void)audioLevelUpdated:(float)averagePower
{
    [self.delegate audioOutputChangedWithMicLevel:averagePower];
    // 처리 필요.
}

- (void)stopPlaying
{
    [self.audioOutput insertObject:[GAAudioInputFile emptyInput] atIndex:0];
    [self.delegate audioOutputStopped];
}

#pragma mark - Generator

//+ (instancetype)sharedOutput {
//    static id sharedInstance;
//    if (sharedInstance == nil) {
//        sharedInstance = [[self alloc] init];
//    }
//    return sharedInstance;
//}

- (instancetype)init {
    if (self = [super init]) {
        //Start the audio session:
        self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:NO];
        
        NSError *errorAudioSetup = NULL;
        BOOL result = [self.audioController start:&errorAudioSetup];
        if ( !result ) NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
        
        AEBlockChannel *myBlockChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
            
            for ( int i=0; i<frames; i++ ) {
                stk::StkFloat sample = 0;
                if (self.audioOutput.count < 1) {
                    sample = 0;
                }
                else if (self.audioOutput.count == 1) {
                    GAAudioInputFile *afi = self.audioOutput[0];
                    sample = afi.tick;
                }
                else {
                    for (int i = (int)self.audioOutput.count-1; i>0; i--) {
                        GAAudioInputFile *afi = self.audioOutput[i];
                        sample += afi.tick * afi.currentAmplitude;
                        
                        if (afi.isPlaying == NO)
                            [self.audioOutput removeObject:afi];
                    }
                    GAAudioInputFile *afi = self.audioOutput[0];
                    sample += afi.tick;
                }
                
                ((float*)audio->mBuffers[0].mData)[i] =
                ((float*)audio->mBuffers[1].mData)[i] = reverb.tick(sample);
            }
            
        }];
        myBlockChannel.volume = 0.6;
        [self.audioController addChannels:@[myBlockChannel]];
        self.audioOutput = [NSMutableArray arrayWithCapacity:10];
        
        // initialize GA classes.
        self.audioInputTable = [[GAAudioInputTable alloc] init];
        int baseMidiNumber = (int)self.audioInputTable.range.location;
        int note = baseMidiNumber%12;
        int octave = baseMidiNumber/12;
        if (note < 6)
            octave--;
        [GASettings sharedSetting].baseNote = 6 + octave*12;
        
        self.fingeringProcessor = [[GAFingeringProcessor alloc] init];
        self.fingeringProcessor.delegate = self;
        
        self.motionProcessor = [[GAMotionProcessor alloc] init];
        self.motionProcessor.delegate = self;
        [self.motionProcessor startUpdate];
        
        [self updateSettings];
    }
    return self;
}

- (void)updateSettings
{
    [self.fingeringProcessor updateSettings];

    GASettings *settings = [GASettings sharedSetting];
    reverb.setEffectMix(settings.reverbMix);
    reverb.setT60(settings.reverbTime);
    motionSensitivity = settings.motionSensitivity;
    
    if (settings.isTouchMode) {
        [self.micProcessor stopUpdate];
    }
    else {
        if (self.micProcessor == nil) 
            self.micProcessor = [GAMicInputProcessor micInputProcessor];

        self.micProcessor.delegate = self;
        [self.micProcessor startUpdate];
    }
}

@end
