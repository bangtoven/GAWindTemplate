//
//  GASettingsViewController.m
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import "GASettingsViewController.h"
#import "GAMicInputProcessor.h"
#import "GAAudioOutputProcessor.h"
#import "GASettings.h"

@interface GASettingsViewController () <GABlowProcessorDelegate> {
    GASettings *settings;
    GAMicInputProcessor *blowProcessor;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *playModeSegment;

@property (weak, nonatomic) IBOutlet F3BarGauge *micInputGaugeBar;
@property (weak, nonatomic) IBOutlet UISlider *micThresholdSlider;

@property (weak, nonatomic) IBOutlet UILabel *baseNoteLabel;
@property (weak, nonatomic) IBOutlet UIStepper *baseNoteStepper;
@property (weak, nonatomic) IBOutlet UILabel *baseNoteShiftLabel;


@property (weak, nonatomic) IBOutlet UISlider *reverbTimeSlider;
@property (weak, nonatomic) IBOutlet UISlider *reverbMixSlider;

@end

@implementation GASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    settings = [GASettings sharedSetting];

    self.playModeSegment.selectedSegmentIndex = settings.isTouchMode;
    [self playModeChanged:self];
    
    self.micThresholdSlider.value = settings.micSensitivity;
    [self micSensitivityChanged:self];
    
    self.baseNoteStepper.value = settings.keyShift;
    [self baseNoteChanged:self];
    
    self.reverbTimeSlider.value = settings.reverbTime;
    self.reverbMixSlider.value = settings.reverbMix;
}

- (IBAction)playModeChanged:(id)sender {
    if (self.playModeSegment.selectedSegmentIndex==1) {
        [blowProcessor stopUpdate];
        self.micThresholdSlider.enabled = NO;
        self.micInputGaugeBar.alpha = 0.5;
    }
    else {
        self.micThresholdSlider.enabled = YES;
        self.micInputGaugeBar.alpha = 1.0;
        //    blowProcessor = [[GABlowProcessor alloc] init];
        //    blowProcessor.delegate = self;
        //    [blowProcessor startUpdate];
    }
}

- (IBAction)micSensitivityChanged:(id)sender {
    float threshold = self.micThresholdSlider.value;
    self.micInputGaugeBar.normalThreshold = threshold;
    self.micInputGaugeBar.warnThreshold = (2*threshold + 1.0) / 3.0;
    self.micInputGaugeBar.dangerThreshold = (threshold + 2.0) / 3.0;
    
    [self.micInputGaugeBar resetPeak];
}

- (void)audioLevelUpdated:(float)averagePower {
    self.micInputGaugeBar.value = averagePower;
}

- (IBAction)baseNoteChanged:(id)sender {
    int value = (int)self.baseNoteStepper.value;
    GAAudioOutputProcessor *aop = [GAAudioOutputProcessor sharedOutput];
    NSString *name = [aop nameOfKey:value];
    self.baseNoteLabel.text = name;
    if (value == 0)
        self.baseNoteShiftLabel.text = @"";
    else if (value > 0)
        self.baseNoteShiftLabel.text = [NSString stringWithFormat:@"+%d",value];
    else if (value < 0)
        self.baseNoteShiftLabel.text = [NSString stringWithFormat:@"%d",value];
}

- (IBAction)resetBaseNote:(id)sender {
    self.baseNoteStepper.value = 0;
    [self baseNoteChanged:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if it is unwind...
    settings.touchMode = self.playModeSegment.selectedSegmentIndex==1;
    settings.micSensitivity = self.micThresholdSlider.value;
    settings.keyShift = self.baseNoteStepper.value;
    settings.reverbTime = self.reverbTimeSlider.value;
    settings.reverbMix = self.reverbMixSlider.value;
    [settings synchronize];
    
    [blowProcessor stopUpdate];
}

@end
