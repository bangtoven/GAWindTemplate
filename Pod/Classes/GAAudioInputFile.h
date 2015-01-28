//
//  GAAudioInputFile.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 28..
//
//

#import <Foundation/Foundation.h>

@interface GAAudioInputFile : NSObject

- (instancetype)initWithFileName:(NSString*)fileName andPitch:(int)pitch;
+ (instancetype)emptyInput;

@property (nonatomic,strong) NSString *noteName;
@property (nonatomic) int midiNumber;

@property (nonatomic,readonly) double tick;
@property (nonatomic,readonly) BOOL isPlaying;

- (double)currentAmplitude;
- (void)setRate:(double)rate;

@end
