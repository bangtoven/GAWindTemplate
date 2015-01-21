//
//  ViewController.m
//  Hun
//
//  Created by 방정호 on 2014. 10. 31..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAPlayViewController.h"
#import "GAAudioOutputProcessor.h"
#import "GAMotionProcessor.h"
#import "GABlowProcessor.h"
#import "GAFingeringProcessor.h"

@interface GAPlayViewController () <UIActionSheetDelegate,GAFingeringProcessorDelegate, GABlowProcessorDelegate> {
    GAMotionProcessor *motionProcessor;
    GABlowProcessor *blowProcessor;
    
    GAAudioOutputProcessor *audioOutput;

    GAFingeringProcessor* fingeringProcessor;

    float micSensitivity;
    BOOL isBlowing;
    BOOL alwaysBlowing;

    float intensity;
}

@end

@implementation GAPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.needs3Octave)
        self.octaveButton.isUpDown = YES;
    
    self.keyNameLabel.text = @"";
    
    fingeringProcessor = [GAFingeringProcessor new];
    fingeringProcessor.delegate = self;
    
    audioOutput = [GAAudioOutputProcessor sharedOutput];//[[GAAudioOutputProcessor alloc] init];
    
    motionProcessor = [[GAMotionProcessor alloc] init];
    motionProcessor.delegate = audioOutput;
    [motionProcessor startUpdate];
    
//    micSensitivity = [GABlowProcessor micSensitivity];
//    blowProcessor = [[GABlowProcessor alloc] init];
//    blowProcessor.delegate = self;
//    [blowProcessor startUpdate];
    
    alwaysBlowing = YES;
}

- (IBAction)holeButtonAction:(GAButtonHole *)sender {
    [fingeringProcessor keyHoleInLocation:(int)sender.location changedTo:sender.closed];
}

- (IBAction)octaveButtonAction:(GAButtonOctave *)sender {
    [fingeringProcessor octaveChangedTo:sender.octave];
}

- (void)fingeringChangedWithKey:(int)key{
    NSLog(@"%d", key);
    if (FINGERING_ALL_OPEN) {
        [audioOutput stopPlaying];
    }
    else {
        [audioOutput changeNote:(int)key];
    }
}

- (void)audioLevelUpdated:(float)averagePower {
    isBlowing = (averagePower > micSensitivity);
    
//    [self playSound];
}

- (IBAction)autoBlowing:(UISwitch*)sender {
    alwaysBlowing = sender.isOn;
    if (alwaysBlowing)
        [blowProcessor stopUpdate];
    else
        [blowProcessor startUpdate];
}

- (IBAction)settingButtonAction:(id)sender {
    self.octaveButton.isUpDown = !self.octaveButton.isUpDown;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"설정",@"사용법",@"정보", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [self performSegueWithIdentifier:@"show settings" sender:nil];
            break;
        }
        default:
            break;
    }
}

- (IBAction)backToPlayView:(UIStoryboardSegue*)sender
{
    NSLog(@"I am back!");
}

//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
//{
//
//}
//
//- (void)actionSheetCancel:(UIActionSheet *)actionSheet
//{
//
//}

//// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
//// If not defined in the delegate, we simulate a click in the cancel button
//- (void)actionSheetCancel:(UIActionSheet *)actionSheet;
//
//- (void)didPresentActionSheet:(UIActionSheet *)actionSheet;  // after animation
//
//- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
//

@end
