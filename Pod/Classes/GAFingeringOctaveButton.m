//
//  GAButtonOctave.m
//  afasdf
//
//  Created by Jungho Bang on 2015. 1. 20..
//  Copyright (c) 2015년 bangtoven. All rights reserved.
//

#import "GAFingeringOctaveButton.h"
#import "NSBundle+GATemplate.h"

@interface GAFingeringOctaveButton () {
    UIImage *downImage, *upImage;
}

@end

@implementation GAFingeringOctaveButton
@synthesize octave = _octave;

- (void)setIsUpDown:(BOOL)isUpDown
{
    NSBundle *bundle = [NSBundle templateBundle];
    if (isUpDown) {
        UIImage *image = [UIImage imageNamed:@"split_octave.png" inBundle:bundle compatibleWithTraitCollection:nil];
        [self setImage:image forState:UIControlStateNormal];
        [self setNeedsDisplay];

        downImage = [UIImage imageNamed:@"split_octave_down.png" inBundle:bundle compatibleWithTraitCollection:nil];
        upImage = [UIImage imageNamed:@"split_octave_up.png" inBundle:bundle compatibleWithTraitCollection:nil];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"octave.png" inBundle:bundle compatibleWithTraitCollection:nil];
        [self setImage:image forState:UIControlStateNormal];
        
        image = [UIImage imageNamed:@"octave_active.png" inBundle:bundle compatibleWithTraitCollection:nil];
        [self setImage:image forState:UIControlStateHighlighted];

        [self setNeedsDisplay];
    }
    _isUpDown = isUpDown;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isUpDown) {
        CGPoint loc = [[touches anyObject] locationInView:self];
        BOOL isDown = loc.x < loc.y;
        if (isDown && self.octave!=1) {
            _octave = 1;
            [self setImage:downImage forState:UIControlStateHighlighted];
        }
        else if (!isDown && self.octave!=-1) {
            _octave = -1;
            [self setImage:upImage forState:UIControlStateHighlighted];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

-(int)octave
{
    if (self.isUpDown)
        return self.closed ? _octave : 0;
    else
        return self.closed ? 1 : 0;
}

@end
