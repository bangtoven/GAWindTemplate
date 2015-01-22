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
#import "PitShift.h"
#import "FileWvIn.h"

#import "GASettings.h"


#pragma mark - GAAudioFileInput
@interface GAAudioFileInput : NSObject
{
    stk::FileWvIn fileWvIn;
    int amplitude;
    double base;
}

- (instancetype)initWithFileName:(NSString*)fileName andPitch:(int)pitch;
+ (instancetype)emptyInput;

@property (nonatomic,readonly) stk::StkFloat tick;
@property (nonatomic,readonly) BOOL isPlaying;

- (stk::StkFloat) currentAmplitude;
- (void)setRate:(stk::StkFloat)rate;

@end
#define MAX_AMPLITUDE 440
@implementation GAAudioFileInput

- (instancetype)init {
    if (self = [super init]) {
        amplitude = MAX_AMPLITUDE;
    }
    return self;
}

- (instancetype)initWithFileName:(NSString*)fileName andPitch:(int)pitch {
    if (self = [super init]) {
        std::string path = [[[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"] cStringUsingEncoding:NSASCIIStringEncoding];
        fileWvIn.openFile(path);
        base = pow(1.0594, pitch);
        fileWvIn.setRate(base);
        amplitude = MAX_AMPLITUDE;
    }
    return self;
}

+ (instancetype)emptyInput {
    return [[GAAudioFileInput alloc] init];
}

- (void)setRate:(stk::StkFloat)rate
{
    if (fileWvIn.isOpen())
        fileWvIn.setRate(base*rate);
}

- (stk::StkFloat)tick {
    return fileWvIn.isOpen() ? fileWvIn.tick() : 0;
}

- (stk::StkFloat)currentAmplitude {
    stk::StkFloat ratio = amplitude / (double)MAX_AMPLITUDE;
    
    if (amplitude>0)
        amplitude--;
    
    return ratio;
}

- (BOOL)isPlaying {
    return (amplitude!=0) && (fileWvIn.isFinished()==false);
}

@end

#pragma mark - GAAudioOutputProcessor

@interface GAAudioOutputProcessor () {
    NSArray *sampleTable;
    int baseOctave;
    int fingeringToNote;
    int keyShift;
    float motionSensitivity;
    
    NSMutableArray *audioOutput;
    stk::NRev reverb;
    
    double lastAccel;
}
@property (strong) AEAudioController *audioController;
@property (strong) GAMotionProcessor *motionProcessor;
@end

@implementation GAAudioOutputProcessor

- (void)updateSettings
{
    GASettings *settings = [GASettings sharedSetting];
    reverb.setEffectMix(settings.reverbMix);
    reverb.setT60(settings.reverbTime);
    keyShift = settings.keyShift;
    motionSensitivity = settings.motionSensitivity;
}

- (void)fingeringChangedWithKey:(int)key
{
    if (key == FINGERING_ALL_OPEN) 
        [self stopPlaying];
    else {
        key += keyShift;
        NSString *name = [self nameOfKey:key];
        [self.delegate audioOutputChangedToNote:name];
    
        key += fingeringToNote;
        [self changeNote:key];
    }
}

- (void)changeNote:(int)note
{
    int fileNameKey;
    if (note < 0)
        fileNameKey = 0;
    else if (note >= sampleTable.count)
        fileNameKey = (int)sampleTable.count-1;
    else
        fileNameKey = note;
    
    NSDictionary *sampleInfo = sampleTable[fileNameKey];
    NSString *fileName = sampleInfo[@"fileName"];
    int pitch = [sampleInfo[@"pitch"] intValue] + (note-fileNameKey);
    
    GAAudioFileInput *input = [[GAAudioFileInput alloc] initWithFileName:fileName andPitch:pitch];
    
    [audioOutput insertObject:input atIndex:0];
}

- (void)stopPlaying
{
    [audioOutput insertObject:[GAAudioFileInput emptyInput] atIndex:0];
}

- (void)motionUpdated:(CMDeviceMotion *)motion {
    if (audioOutput.count == 0)
        return;
    
    double accelY = motion.userAcceleration.y;
    double diff = accelY-lastAccel;
    
    if (ABS(diff)>0.005) {
        double adjusted = accelY*motionSensitivity;
        double pitch = erf(adjusted)*2;
        double rate = pow(1.0594, pitch);
        GAAudioFileInput *afi = audioOutput[0];
        [afi setRate:rate];
        
        double factor = 0.4 * motionSensitivity/0.6;
        double volume = erf(accelY)*factor + 0.6;
        AEBlockChannel *myBlockChannel = self.audioController.channels.lastObject;
        myBlockChannel.volume = volume;

        lastAccel = accelY;
    }
}

- (NSString*)nameOfKey:(int)key
{
    static NSArray *keyNameArray = @[@"C",@"Db",@"D",@"Eb",@"E",@"F",@"Gb",@"G",@"Ab",@"A",@"Bb",@"B"];
    key += 6 + baseOctave*12;
    int octave = key/12;
    int index = key%12;
    return [NSString stringWithFormat:@"%@%d",keyNameArray[index],octave];
}

- (void)makeOneOctaveHigher
{
    baseOctave += 1;
    fingeringToNote += 12;
}

#pragma mark - Generator

+ (instancetype)sharedOutput {
    static id sharedInstance;
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize sample input
        sampleTable = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioInputTable" ofType:@"plist"]];
        
        NSDictionary *firstSample = sampleTable[0];
        int note = [firstSample[@"note"] intValue];
        int octave = [firstSample[@"octave"] intValue];
        baseOctave = note<6 ? octave-1 : octave;
        fingeringToNote = (-6-note)%12;
        
        self.motionProcessor = [[GAMotionProcessor alloc] init];
        self.motionProcessor.delegate = self;
        [self.motionProcessor startUpdate];
        
        //Start the audio session:
        self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:NO];
        
        NSError *errorAudioSetup = NULL;
        BOOL result = [self.audioController start:&errorAudioSetup];
        if ( !result ) NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
        
        [self updateSettings];
        
        AEBlockChannel *myBlockChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
            
            for ( int i=0; i<frames; i++ ) {
                stk::StkFloat sample = 0;
                if (audioOutput.count < 1) {
                    sample = 0;
                }
                else if (audioOutput.count == 1) {
                    GAAudioFileInput *afi = audioOutput[0];
                    sample = afi.tick;
                }
                else {
                    for (int i = (int)audioOutput.count-1; i>0; i--) {
                        GAAudioFileInput *afi = audioOutput[i];
                        sample += afi.tick * afi.currentAmplitude;
                        
                        if (afi.isPlaying == NO)
                            [audioOutput removeObject:afi];
                    }
                    GAAudioFileInput *afi = audioOutput[0];
                    sample += afi.tick;
                }
                
                ((float*)audio->mBuffers[0].mData)[i] =
                ((float*)audio->mBuffers[1].mData)[i] = reverb.tick(sample);
            }
            
        }];
        
        myBlockChannel.volume = 0.6;
        
        [self.audioController addChannels:@[myBlockChannel]];
        
        audioOutput = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

@end
