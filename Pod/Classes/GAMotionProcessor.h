//
//  GAMotionProcessor.h
//  Hun
//
//  Created by Jungho Bang on 2014. 11. 6..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@protocol GAMotionProcessorDelegate <NSObject>
-(void)motionUpdatedToAngle:(double)angle;
@end


@interface GAMotionProcessor : NSObject

@property (nonatomic,weak) id<GAMotionProcessorDelegate> delegate;

+(GAMotionProcessor*)motionProcessor;
-(void)startUpdate;
-(void)stopUpdate;

@end
