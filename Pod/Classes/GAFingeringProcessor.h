//
//  GAFingeringProcessor.h
//  Hun
//
//  Created by 방정호 on 2014. 11. 5..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAButtonHole.h"
#import "GAButtonOctave.h"

#define FINGERING_ALL_OPEN INT32_MIN

@protocol GAFingeringProcessorDelegate <NSObject>
- (void)fingeringChangedWithKey:(int)key;
@end

@interface GAFingeringProcessor : NSObject

@property (nonatomic,weak) id<GAFingeringProcessorDelegate> delegate;

- (void)action:(GAButtonHole *)sender;
- (void)octaveAction:(GAButtonOctave *)sender;

@end
