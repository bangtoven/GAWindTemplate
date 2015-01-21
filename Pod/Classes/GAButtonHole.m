//
//  GAHoleButton.m
//  Hun
//
//  Created by 방정호 on 2014. 11. 5..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAButtonHole.h"

@implementation GAButtonHole

- (BOOL)closed {
    return self.highlighted;
}

- (void)setHighlighted:(BOOL)highlighted{
    if (highlighted!=self.highlighted) {
        [super setHighlighted:highlighted];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
