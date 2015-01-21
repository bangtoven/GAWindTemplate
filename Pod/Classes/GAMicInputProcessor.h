//
//  GABlowProcessor.h
//  asdf
//
//  Created by Jungho Bang on 2014. 11. 14..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol GABlowProcessorDelegate <NSObject>
- (void)audioLevelUpdated:(float)averagePower;
@end


@interface GAMicInputProcessor : NSObject

+ (float)micSensitivity;
+ (void)setMicSensitivity:(float)sensitivity;

@property (nonatomic, weak) id <GABlowProcessorDelegate> delegate;

- (void)startUpdate;
- (void)stopUpdate;

@end
