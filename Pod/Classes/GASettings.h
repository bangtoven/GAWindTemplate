//
//  GAGlobalSetting.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import <Foundation/Foundation.h>

@interface GASettings : NSObject

+ (instancetype)sharedSetting;

@property (readonly) BOOL isTouchMode;
@property (readonly) int keyShift;

@end
