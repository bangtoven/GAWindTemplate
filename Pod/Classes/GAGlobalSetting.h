//
//  GAGlobalSetting.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import <Foundation/Foundation.h>

@interface GAGlobalSetting : NSObject

+ (instancetype)sharedSetting;
- (BOOL)isTouchMode;

@end
