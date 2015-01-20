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
    NSMutableArray *audioOutput;
    
    stk::NRev *reverb;
}
@property AEAudioController *audioController;
@end

@implementation GAAudioOutputProcessor

+ (instancetype)sharedOutput {
    static GAAudioOutputProcessor *sharedInstance;
    if (sharedInstance == nil) {
        sharedInstance = [[GAAudioOutputProcessor alloc] init];
    }
    return sharedInstance;
}

- (void)setReverbEffectMix:(double)mix {
    reverb->setEffectMix(mix);
}
- (void)setReverbDelay:(double)delay {
    reverb->setT60(delay);
}

- (void)changeNote:(int)note {
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

- (void)stopPlaying {
    [audioOutput insertObject:[GAAudioFileInput emptyInput] atIndex:0];
}

- (void)motionUpdatedToAngle:(double)angle {
    if (audioOutput.count == 0) {
        return;
    }
    
    GAAudioFileInput *afi = audioOutput[0];
    
    double ppitch = angle*2/3;
    ppitch = erf(ppitch)*2;
    
    double rate = pow(1.0594, ppitch);
    [afi setRate:rate];
    
    double volume = erf(angle)*0.4 + 0.6;
    
    AEBlockChannel *myBlockChannel = self.audioController.channels.lastObject;
    myBlockChannel.volume = volume;
}

- (instancetype)init {
    if (self = [super init]) {
        sampleTable = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioInputTable" ofType:@"plist"]];
        
        audioOutput = [NSMutableArray arrayWithCapacity:10];
        
        //Start the audio session:
        self.audioController = [[AEAudioController alloc] initWithAudioDescription:
                                [AEAudioController nonInterleavedFloatStereoAudioDescription]
                                                                      inputEnabled:NO
                                ];
        
        NSError *errorAudioSetup = NULL;
        BOOL result = [self.audioController start:&errorAudioSetup];
        if ( !result ) NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
        
        reverb = new stk::NRev();
        reverb->setT60(1.8);
        reverb->setEffectMix(0.25);

        AEBlockChannel *myBlockChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
            
            //The STK classes compute and output one sample at a time,
            //place them in the frames of the buffer:
            
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
                ((float*)audio->mBuffers[1].mData)[i] = reverb->tick(sample);
            }
            
        }];
        
        myBlockChannel.volume = 0.6;
        
        [self.audioController addChannels:@[myBlockChannel]];
    }
    return self;
}

@end
