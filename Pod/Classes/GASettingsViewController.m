//
//  GASettingsViewController.m
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import "GASettingsViewController.h"
#import "GABlowProcessor.h"
#import "GAAudioOutputProcessor.h"

@interface GASettingsViewController () <GABlowProcessorDelegate> {
    GABlowProcessor *blowProcessor;
    BOOL asdf;
}
@end

@implementation GASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    blowProcessor = [[GABlowProcessor alloc] init];
//    blowProcessor.delegate = self;
//    [blowProcessor startUpdate];

    self.micThresholdSlider.value = [GABlowProcessor micSensitivity];
    [self sensitivityChanged:self];
}

- (IBAction)sensitivityChanged:(id)sender {
    float threshold = self.micThresholdSlider.value;
    self.micInputGaugeBar.normalThreshold = threshold;
    self.micInputGaugeBar.warnThreshold = (2*threshold + 1.0) / 3.0;
    self.micInputGaugeBar.dangerThreshold = (threshold + 2.0) / 3.0;
    
    [self.micInputGaugeBar resetPeak];
}

- (IBAction)reverbDelayChanged:(id)sender {
    [[GAAudioOutputProcessor sharedOutput] setReverbDelay:self.reverbDelaySlider.value];
}

- (IBAction)reverbMixChanged:(id)sender {
    [[GAAudioOutputProcessor sharedOutput] setReverbEffectMix:self.reverbMixSlider.value];
}

- (void)audioLevelUpdated:(float)averagePower {
    self.micInputGaugeBar.value = averagePower;
}

- (IBAction)saveAndGoBack {
    [GABlowProcessor setMicSensitivity:self.micThresholdSlider.value];
    [blowProcessor stopUpdate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 11;
        case 1:
            return 3;
        default:
            return 0;
    }

}
//// returns width of column and height of row for each component.
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            NSArray *noteNameArray = @[@"C",@"Db",@"D",@"Eb",@"E",@"F",@"Gb",@"G",@"Ab",@"A",@"Bb",@"B"];
            return noteNameArray[row];
        }
        case 1:
            return [NSString stringWithFormat:@"%d",row+2];
        default:
            return @"";
    }
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;



@end
