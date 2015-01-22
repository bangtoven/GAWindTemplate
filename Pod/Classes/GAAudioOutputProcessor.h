//
//  GAAudioOutputProcessor.h
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAFingeringProcessor.h"

@protocol GAAudioOutputDelegate <NSObject>
- (void)audioOutputChangedToNote:(NSString*)note;
@end

@interface GAAudioOutputProcessor : NSObject <GAFingeringProcessorDelegate>

@property (nonatomic, weak) id<GAAudioOutputDelegate> delegate;

+ (instancetype)sharedOutput;

- (void)makeOneOctaveHigher;
- (void)updateSettings;

- (void)stopPlaying;

- (NSString*)nameOfKey:(int)key;

@end
