//
//  GAAudioInputFile.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 28..
//
//

#import "GAAudioInputFile.h"
#import "FileWvIn.h"

@interface GAAudioInputFile ()
{
    stk::FileWvIn fileWvIn;
    int amplitude;
    double base;
}
@end

#define MAX_AMPLITUDE 440
@implementation GAAudioInputFile

- (instancetype)initWithFileName:(NSString*)fileName andPitch:(int)pitch {
    if (self = [super init]) {
        std::string path = [[[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"] cStringUsingEncoding:NSASCIIStringEncoding];
        fileWvIn.openFile(path);
        if (pitch!=0) {
            base = pow(1.0594, pitch);
            fileWvIn.setRate(base);
        }
        else
            base = 1.0;
        amplitude = MAX_AMPLITUDE;
    }
    return self;
}

+ (instancetype)emptyInput {
    return [[self alloc] initEmpty];
}

- (instancetype)initEmpty {
    if (self = [super init]) {
        amplitude = MAX_AMPLITUDE;
    }
    return self;
}

- (void)setRate:(double)rate
{
    if (fileWvIn.isOpen())
        fileWvIn.setRate(base*rate);
}

- (double)tick {
    return fileWvIn.isOpen() ? fileWvIn.tick() : 0;
}

- (double)currentAmplitude {
    stk::StkFloat ratio = amplitude / (double)MAX_AMPLITUDE;
    
    if (amplitude>0)
        amplitude--;
    
    return ratio;
}

- (BOOL)isPlaying {
    return (amplitude!=0) && (fileWvIn.isFinished()==false);
}

@end
