//
//  GASettingsViewController.h
//  Hun
//
//  Created by Jungho Bang on 2015. 1. 7..
//  Copyright (c) 2015년 CAT@SNU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F3BarGauge.h"

@interface GASettingsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *playModeSegment;
@property (weak, nonatomic) IBOutlet F3BarGauge *micInputGaugeBar;
@property (weak, nonatomic) IBOutlet UISlider *micThresholdSlider;
@property (weak, nonatomic) IBOutlet UIPickerView *lowestNotePicker;
@property (weak, nonatomic) IBOutlet UISlider *reverbDelaySlider;
@property (weak, nonatomic) IBOutlet UISlider *reverbMixSlider;

@end
