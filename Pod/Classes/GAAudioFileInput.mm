//
//  GAAudioFileInput.m
//  STK on iOS
//
//  Created by Jungho Bang on 2015. 1. 1..
//  Copyright (c) 2015년 ariel. All rights reserved.
//

#import "GAAudioFileInput.h"

@interface GAAudioFileInput ()
{
    stk::FileWvIn fileWvIn;
    int amplitude;
    double base;
}
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
