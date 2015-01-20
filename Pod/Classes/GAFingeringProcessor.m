//
//  GAFingeringProcessor.m
//  Hun
//
//  Created by 방정호 2014. 11. 5..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAFingeringProcessor.h"
#import "GAGlobalSetting.h"

@interface GAFingeringProcessor () {
    NSTimer *timer;
}

@property (nonatomic,strong) NSMutableString *buttonStatus;
@property (nonatomic) int octaveStatus;
@property (nonatomic,strong) NSArray *fingeringTable;
//@property (nonatomic,strong) NSArray *keyNameArray;
//        self.keyNameArray = @[@"C",@"Db",@"D",@"Eb",@"E",@"F",@"Gb",@"G",@"Ab",@"A",@"Bb",@"B"];

@property (nonatomic) int currentKey;

@end

@implementation GAFingeringProcessor

- (id)init {
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"GAWindTemplate" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        self.fingeringTable = [NSArray arrayWithContentsOfFile:[bundle pathForResource:@"GAFingeringTable" ofType:@"plist"]];

        self.buttonStatus = [NSMutableString stringWithString:@"00000"];
        self.currentKey = -1;
    }
    return self;
}

- (void)action:(GAButtonHole *)sender {
    NSInteger location = sender.location;
    BOOL closed = sender.closed;
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

- (void)octaveAction:(GAButtonHole *)sender {
    self.octaveStatus = sender.closed ? 1 : 0;
    [self prepareKeyToQueue];
}

- (void)prepareKeyToQueue {
    if (timer)
        [timer invalidate];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(sendToDelegate) userInfo:nil repeats:NO];
}

- (void)sendToDelegate {
    timer = nil;

    if ([GAGlobalSetting sharedSetting].isTouchMode &&
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
