//
//  GAAudioFileInput.h
//  STK on iOS
//
//  Created by Jungho Bang on 2015. 1. 1..
//  Copyright (c) 2015년 ariel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileWvIn.h"

@interface GAAudioFileInput : NSObject

- (instancetype)initWithFileName:(NSString*)fileName andPitch:(int)pitch;
+ (instancetype)emptyInput;

@property (nonatomic,readonly) stk::StkFloat tick;
@property (nonatomic,readonly) BOOL isPlaying;

- (stk::StkFloat) currentAmplitude;
- (void)setRate:(stk::StkFloat)rate;

@end
