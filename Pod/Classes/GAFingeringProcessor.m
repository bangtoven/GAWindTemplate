//
//  GAFingeringProcessor.m
//  Hun
//
//  Created by 방정호 2014. 11. 5..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAFingeringProcessor.h"
#import "GASettings.h"

@interface GAFingeringProcessor () {
    NSTimer *timer;
    BOOL isTouchMode;
    int fingeringToMidiNumber;
}

@property (nonatomic,strong) NSArray *fingeringTable;

@property (nonatomic,strong) NSMutableString *buttonStatus;
@property (nonatomic) int octaveStatus;
@property (nonatomic) int currentKey;

@end

@implementation GAFingeringProcessor

- (instancetype)init
{
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];
        self.fingeringTable = [NSArray arrayWithContentsOfFile:[bundle pathForResource:@"GAFingeringTable" ofType:@"plist"]];
        
        self.buttonStatus = [NSMutableString stringWithString:@"00000"];
        self.currentKey = 10;
        [self updateSettings];
    }
    return self;
}

- (void)updateSettings
{
    GASettings *settings = [GASettings sharedSetting];
    isTouchMode = settings.controlMode == GAControlModeTouch;
    fingeringToMidiNumber = settings.baseNote + settings.keyShift;
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
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(sendToDelegate) userInfo:nil repeats:NO];
}

- (void)sendToDelegate {
    timer = nil;

    if (isTouchMode &&
        self.octaveStatus == 0 &&
        [self.buttonStatus isEqualToString:@"00000"]) {
        [self.delegate fingeringChangedWithNote:FINGERING_ALL_OPEN];
    }
    else {
        int note = self.currentKey + self.octaveStatus*12 + fingeringToMidiNumber;
        [self.delegate fingeringChangedWithNote:note];
    }
}

@end
