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

#define VOLUME_QUEUE_SIZE 20

@interface GAAudioOutputProcessor () <GAMicInputProcessorDelegate> {
    stk::NRev reverb;
    
    BOOL isPlaying;
    int lastNote;
    
    float micThreshold;

    BOOL controlTiltForVolume;
    float motionSensitivity;
    double lastAccel;
    double lastAttitude;
    
    float micGain;
    float motionGain;
    float tiltGain;
    int lastQueueIndex;
    float volumeQueue[VOLUME_QUEUE_SIZE];
    float masterVolume;
}

@property (nonatomic, strong) GAMicInputProcessor *micProcessor;
@property (nonatomic, strong) GAMotionProcessor *motionProcessor;

@property (nonatomic, strong) GAAudioInputTable *audioInputTable;
@property (strong) AEAudioController *audioController;
@property (strong) NSMutableArray *audioOutput;

@end

@implementation GAAudioOutputProcessor

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
                
                sample *= masterVolume;
                
                ((float*)audio->mBuffers[0].mData)[i] =
                ((float*)audio->mBuffers[1].mData)[i] = reverb.tick(sample);
            }
            
        }];
        
        [self.audioController addChannels:@[myBlockChannel]];
        self.audioOutput = [NSMutableArray arrayWithCapacity:10];
        
        // initialize GA classes.
        for (int i=0; i<VOLUME_QUEUE_SIZE; i++) {
            volumeQueue[i] = 0;
        }
        lastQueueIndex = 0;
        
        lastNote = FINGERING_ALL_OPEN;
        
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
    [self.micProcessor updateSettings];
    
    GASettings *settings = [GASettings sharedSetting];
    reverb.setEffectMix(settings.reverbMix);
    reverb.setT60(settings.reverbTime);
    motionSensitivity = settings.motionSensitivity;
    
    switch (settings.controlMode) {
        case GAControlModeTouch: {
            [self.micProcessor stopUpdate];
            self.micProcessor = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            
            micGain = 1.0;
            isPlaying = YES;
            controlTiltForVolume = YES;
            break;
        }
        case GAControlModeBlowWithTilt: {
            micThreshold = settings.micThreshold;
            self.micProcessor = [[GAMicInputProcessor alloc] initWithDelegate:self andProcessThreshold:YES];
            [self.micProcessor startUpdate];
            
            micGain = 1.0;
            controlTiltForVolume = YES;
            break;
        }
        case GAControlModeBlowWithOnlyMic: {
            micThreshold = settings.micThreshold;
            self.micProcessor = [[GAMicInputProcessor alloc] initWithDelegate:self andProcessThreshold:YES];
            [self.micProcessor startUpdate];
            
            controlTiltForVolume = NO;
            tiltGain = 1.0;
            break;
        }
    }
}

- (void)fingeringChangedWithNote:(int)note
{
    [self playNote:note];
}

- (void)playNote:(int)note
{
    if (note == FINGERING_ALL_OPEN)
        [self stopPlaying];
    else {
        [self.delegate audioOutputNoteChanged:[GAAudioInputTable nameOfNote:note]];
        lastNote = note;
        if (isPlaying) {
            GAAudioInputFile *input = [self.audioInputTable audioInputOfNote:note];
            [self.audioOutput insertObject:input atIndex:0];
        }
    }
}

- (void)motionUpdated:(CMDeviceMotion *)motion {
    if (self.audioOutput.count == 0)
        return;
    
    BOOL updated = NO;
    {
        double accelY = motion.userAcceleration.y;
        double diff = accelY-lastAccel;
        
        if (ABS(diff)>0.005) {
            updated = YES;
            
            double adjusted = accelY*motionSensitivity;
            double pitch = erf(adjusted)*2;
            double rate = pow(1.0594, pitch);
            GAAudioInputFile *afi = self.audioOutput[0];
            [afi setRate:rate];
            
            double factor = 0.4 * motionSensitivity/0.6;
            motionGain = erf(accelY)*factor + 0.6;
            
            lastAccel = accelY;
        }
    }

    if (controlTiltForVolume) {
        double pitch = motion.attitude.pitch;
        double diff = pitch-lastAttitude;
        
        if (ABS(diff)>0.005) {
            updated = YES;
            
            double angle = pitch/M_PI*180.0 + 90;
            
            if (angle < 30)
                tiltGain = 0;
            else if (angle < 120)
                tiltGain = (angle-30)/90.;
            else
                tiltGain = 1;
            
            lastAttitude = pitch;
        }
    }
    
    if (updated)
        [self updateVolume];
}

- (void)micInputStarted
{
    isPlaying = YES;
    [self playNote:lastNote];
}

- (void)micInputStopped
{
    isPlaying = NO;
    [self stopPlaying];
}

- (void)micInputLevelUpdated:(float)averagePower
{
    if (controlTiltForVolume==NO) {
        float volume = (averagePower-micThreshold) / (1-micThreshold);
        micGain = (9*micGain+volume)/10;
        [self updateVolume];
        
        [self.delegate audioOutputVolumeChanged:volume];
    }
}

- (void)updateVolume
{
    double volume = motionGain * micGain * tiltGain;
    if (volume > 1) volume = 1;
    
    double sum = masterVolume*VOLUME_QUEUE_SIZE;
    sum -= volumeQueue[lastQueueIndex];
    sum += volume;
    volumeQueue[lastQueueIndex] = volume;
    masterVolume = sum/(float)VOLUME_QUEUE_SIZE;

    lastQueueIndex++;
    if (lastQueueIndex>=VOLUME_QUEUE_SIZE)
        lastQueueIndex = 0;
}


- (void)stopPlaying
{
    [self.audioOutput insertObject:[GAAudioInputFile emptyInput] atIndex:0];
    [self.delegate audioOutputStopped];
}

- (void)stopAudioOutput
{
    [self.micProcessor stopUpdate];
    [self stopPlaying];
}

@end
