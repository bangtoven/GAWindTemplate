//
//  GAAppDelegate.m
//  GAWindTemplate
//
//  Created by CocoaPods on 01/20/2015.
//  Copyright (c) 2014 Jungho Bang. All rights reserved.
//

#import "GAAppDelegate.h"
#import "GAAudioOutputProcessor.h"

@implementation GAAppDelegate

- (void)initialize:(GAPlayViewController *)pvc
{
    NSLog(@"initialize called");
    
    [pvc setNeedsUpDownOctave:YES];
//    [pvc setAudioOutput:[GAAudioOutputProcessor sharedOutput]];
}

@end
