//
//  GAOctaveButton.h
//  afasdf
//
//  Created by Jungho Bang on 2015. 1. 20..
//  Copyright (c) 2015년 bangtoven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAButtonHole.h"

@interface GAButtonOctave : GAButtonHole

@property (nonatomic) BOOL isUpDown;
@property (readonly) int octave;

@end
