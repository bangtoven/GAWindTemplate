//
//  GABlowProcessor.h
//  asdf
//
//  Created by Jungho Bang on 2014. 11. 14..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol GAMicInputProcessorDelegate <NSObject>
-(void)micInputLevelUpdated:(float)averagePower;
@optional
-(void)micInputStarted;
-(void)micInputStopped;
@end

@interface GAMicInputProcessor : NSObject

- (id)initWithDelegate:(id<GAMicInputProcessorDelegate>)delegate andProcessThreshold:(BOOL)process;

-(void)startUpdate;
-(void)updateMeters;
-(void)stopUpdate;

-(void)updateSettings;

@end
