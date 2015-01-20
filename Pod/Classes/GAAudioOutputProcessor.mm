//
//  GAAudioOutputProcessor.m
//  Pods
//
//  Created by bangtoven on 2015. 1. 14..
//
//

#import "GAAudioOutputProcessor.h"

#import "AEAudioController.h"
#import "AEBlockChannel.h"

#import "NRev.h"

#import "GAAudioFileInput.h"

@interface GAAudioOutputProcessor () {
    NSArray *sampleTable;
    NSMutableArray *audioOutput;
    
    stk::NRev *reverb;
    
    double gain, masterVolume;
}
@property AEAudioController *audioController;
@end

@implementation GAAudioOutputProcessor

- (void)changePitch:(double)pitch
{
    if (audioOutput.count == 0) {
        return;
    }
    double rate = pow(1.0594, pitch);
    GAAudioFileInput *afi = audioOutput[0];
    [afi setRate:rate];
}

- (void)changeGain:(double)_gain
{
    gain = _gain;
    [self setVolume];
}

- (void)setMasterVolume:(double)volume
{
    masterVolume = volume;
    [self setVolume];
}

- (void)setVolume
{
    AEBlockChannel *myBlockChannel = self.audioController.channels.lastObject;
    myBlockChannel.volume = masterVolume * gain;
}

- (void)changeNote:(int)note {
    note += 2;
    
    int fileNameKey;
    if (note < 0)
        fileNameKey = 0;
    else if (note >= sampleTable.count)
        fileNameKey = (int)sampleTable.count-1;
    else
        fileNameKey = note;
    
    NSDictionary *sampleInfo = sampleTable[fileNameKey];
    //    NSString *noteName = sampleInfo[@"noteName"];
    //    NSLog(@"%@",noteName);
    
    NSString *fileName = sampleInfo[@"fileName"];
    int pitch = [sampleInfo[@"pitch"] intValue] + (note-fileNameKey);
    
    GAAudioFileInput *input = [[GAAudioFileInput alloc] initWithFileName:fileName andPitch:pitch];
    
    [audioOutput insertObject:input atIndex:0];
}

- (void)stopPlaying {
    [audioOutput insertObject:[GAAudioFileInput emptyInput] atIndex:0];
}

- (instancetype)initWithAudioInputTable:(NSArray*)dictArray {
    if (self = [super init]) {
        sampleTable = [NSArray arrayWithArray:dictArray];
        
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
