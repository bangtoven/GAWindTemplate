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
-(void)audioLevelUpdated:(float)averagePower;
@end


@interface GAMicInputProcessor : NSObject

@property (nonatomic, weak) id <GAMicInputProcessorDelegate> delegate;

+(GAMicInputProcessor*)micInputProcessor;
-(void)startUpdate;
-(void)stopUpdate;

@end
