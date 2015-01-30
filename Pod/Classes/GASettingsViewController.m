//
//  GASettingsViewController.m
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import "GASettingsViewController.h"
#import "GAMicInputProcessor.h"
#import "GASettings.h"
#import "GAAudioInputTable.h"

@interface GASettingsViewController () <GAMicInputProcessorDelegate> {
    GASettings *settings;
    int baseMidiNumber;
}

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *modeCells;

//@property (weak, nonatomic) IBOutlet UISegmentedControl *playModeSegment;

@property (strong) GAMicInputProcessor *micProcessor;
@property (weak, nonatomic) IBOutlet F3BarGauge *micInputGaugeBar;
@property (weak, nonatomic) IBOutlet UISlider *micThresholdSlider;

@property (weak, nonatomic) IBOutlet UILabel *baseNoteLabel;
@property (weak, nonatomic) IBOutlet UIStepper *baseNoteStepper;
@property (weak, nonatomic) IBOutlet UILabel *baseNoteShiftLabel;
@property (weak, nonatomic) IBOutlet UISwitch *displayNoteNameSwitch;

@property (weak, nonatomic) IBOutlet UISlider *motionSensitivitySlider;

@property (weak, nonatomic) IBOutlet UISlider *reverbTimeSlider;
@property (weak, nonatomic) IBOutlet UISlider *reverbMixSlider;

@end

@implementation GASettingsViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *cell in self.modeCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [self selectControlModeCell:indexPath.row];
}

- (void)selectControlModeCell:(NSUInteger)selectedIndex
{
    settings.controlMode = selectedIndex;

    for (UITableViewCell *cell in self.modeCells) {
        if (cell.tag == selectedIndex)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (settings.controlMode == GAControlModeTouch) {
        self.micThresholdSlider.enabled = NO;
        self.micInputGaugeBar.alpha = 0.5;
        [self.micProcessor stopUpdate];
        self.micProcessor = nil;
    }
    else {
        self.micThresholdSlider.enabled = YES;
        self.micInputGaugeBar.alpha = 1.0;
        self.micProcessor = [[GAMicInputProcessor alloc] initWithDelegate:self andProcessThreshold:NO];
        [self.micProcessor startUpdate];
        if (settings.controlMode == GAControlModeBlowWithTilt) {
            self.micInputGaugeBar.warningBarColor = [UIColor greenColor];
            self.micInputGaugeBar.dangerBarColor  = [UIColor greenColor];
        }
        else if (settings.controlMode == GAControlModeBlowWithOnlyMic) {
            self.micInputGaugeBar.warningBarColor = [UIColor yellowColor];
            self.micInputGaugeBar.dangerBarColor  = [UIColor redColor];
        }
        [self.micInputGaugeBar resetPeak];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    settings = [GASettings sharedSetting];
    baseMidiNumber = settings.baseNote;

//    self.playModeSegment.selectedSegmentIndex = settings.isTouchMode;
//    [self playModeChanged:self];
    [self selectControlModeCell:settings.controlMode];
    
    self.micThresholdSlider.value = settings.micThreshold;
    [self micSensitivityChanged:self];
    
    self.baseNoteStepper.value = settings.keyShift;
    [self baseNoteChanged:self];
    
    self.displayNoteNameSwitch.on = settings.displayNoteName;
    
    self.motionSensitivitySlider.value = settings.motionSensitivity;
    
    self.reverbTimeSlider.value = settings.reverbTime;
    self.reverbMixSlider.value = settings.reverbMix;    
}

- (IBAction)micSensitivityChanged:(id)sender {
    float threshold = self.micThresholdSlider.value;
    self.micInputGaugeBar.normalThreshold = threshold;
    self.micInputGaugeBar.warnThreshold = (2*threshold + 1.0) / 3.0;
    self.micInputGaugeBar.dangerThreshold = (threshold + 2.0) / 3.0;
    
    [self.micInputGaugeBar resetPeak];
}

- (void)micInputLevelUpdated:(float)averagePower {
    self.micInputGaugeBar.value = averagePower;
}

- (IBAction)baseNoteChanged:(id)sender {
    int shift = (int)self.baseNoteStepper.value;
    
    NSString *name = [GAAudioInputTable nameOfNote:shift+baseMidiNumber];
    self.baseNoteLabel.text = name;
    if (shift == 0)
        self.baseNoteShiftLabel.text = @"";
    else if (shift > 0)
        self.baseNoteShiftLabel.text = [NSString stringWithFormat:@"+%d",shift];
    else if (shift < 0)
        self.baseNoteShiftLabel.text = [NSString stringWithFormat:@"%d",shift];
}

- (IBAction)resetBaseNote:(id)sender {
    self.baseNoteStepper.value = 0;
    [self baseNoteChanged:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//  settings.touchMode = self.playModeSegment.selectedSegmentIndex==1;
//  연주모드 변경은 셀 선택 시 이미 적용 되었음?
    
    settings.micThreshold = self.micThresholdSlider.value;
    settings.keyShift = self.baseNoteStepper.value;
    settings.displayNoteName = self.displayNoteNameSwitch.on;
    settings.motionSensitivity = self.motionSensitivitySlider.value;
    settings.reverbTime = self.reverbTimeSlider.value;
    settings.reverbMix = self.reverbMixSlider.value;
    [settings synchronize];
    
    [self.micProcessor stopUpdate];
}

@end
