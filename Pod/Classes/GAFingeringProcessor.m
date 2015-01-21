//
//  GAFingeringProcessor.m
//  Hun
//
//  Created by 방정호 2014. 11. 5..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAFingeringProcessor.h"
#import "GASettings.h"
#import "NSBundle+GATemplate.h"

@interface GAFingeringProcessor () {
    NSTimer *timer;
}

@property (nonatomic,strong) NSArray *fingeringTable;

@property (nonatomic,strong) NSMutableString *buttonStatus;
@property (nonatomic) int octaveStatus;
@property (nonatomic) int currentKey;

@end

@implementation GAFingeringProcessor

- (id)init {
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle templateBundle];
        self.fingeringTable = [NSArray arrayWithContentsOfFile:[bundle pathForResource:@"GAFingeringTable" ofType:@"plist"]];

        self.buttonStatus = [NSMutableString stringWithString:@"00000"];
        self.currentKey = 10;
    }
    return self;
}

- (void)keyHoleInLocation:(int)location changedTo:(BOOL)closed {
    [self.buttonStatus replaceCharactersInRange:NSMakeRange(location-1, 1) withString:closed?@"1":@"0"];

    __block int key = -1;
    
    [self.fingeringTable enumerateObjectsUsingBlock:^(NSString *fingering, NSUInteger idx, BOOL *stop) {
        if ([fingering isEqualToString:self.buttonStatus]) {
            key = (int)idx;
            *stop = YES;
        }
    }];
    
    if (key==15) key--; // 15번, 14번은 같은 음.
    
    if (key>10) key--; // 10번, 11번은 같은 음.
    
    if (key != -1) {// && key != self.currentKey) {
        self.currentKey = key;
        [self prepareKeyToQueue];
    }
}

- (void)octaveChangedTo:(int)octave {
    self.octaveStatus = octave;
    [self prepareKeyToQueue];
}

- (void)prepareKeyToQueue {
    if (timer)
        [timer invalidate];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(sendToDelegate) userInfo:nil repeats:NO];
}

- (void)sendToDelegate {
    timer = nil;

    if ([GASettings sharedSetting].isTouchMode &&
        self.octaveStatus == 0 &&
        [self.buttonStatus isEqualToString:@"00000"]) {
        [self.delegate fingeringChangedWithKey:FINGERING_ALL_OPEN];
    }
    else {
        int key = self.currentKey + self.octaveStatus*12;
        [self.delegate fingeringChangedWithKey:key];
    }
}

@end
