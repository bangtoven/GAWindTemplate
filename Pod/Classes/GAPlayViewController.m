//
//  ViewController.m
//  Hun
//
//  Created by 방정호 on 2014. 10. 31..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAPlayViewController.h"
#import "GAMicInputProcessor.h"

@interface GAPlayViewController () <UIActionSheetDelegate,GAAudioOutputDelegate, GABlowProcessorDelegate> {
    GAMicInputProcessor *blowProcessor;
    
    GAFingeringProcessor* fingeringProcessor;

    float micSensitivity;
    BOOL isBlowing;
    BOOL alwaysBlowing;

    float intensity;
}

@property (weak, nonatomic) IBOutlet GAFingeringOctaveButton *octaveButton;
@property (weak, nonatomic) IBOutlet UILabel *keyNameLabel;

@end

@implementation GAPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.needsUpDownOctave)
        self.octaveButton.isUpDown = YES;
    
    self.keyNameLabel.text = @"";
    
    self.audioOutput.delegate = self;
    
    fingeringProcessor = [GAFingeringProcessor new];
    fingeringProcessor.delegate = self.audioOutput;
    
//    micSensitivity = [GABlowProcessor micSensitivity];
//    blowProcessor = [[GABlowProcessor alloc] init];
//    blowProcessor.delegate = self;
//    [blowProcessor startUpdate];
    
    alwaysBlowing = YES;
}

- (IBAction)holeButtonAction:(GAFingeringHoleButton *)sender {
    [fingeringProcessor keyHoleInLocation:(int)sender.location changedTo:sender.closed];
}

- (IBAction)octaveButtonAction:(GAFingeringOctaveButton *)sender {
    [fingeringProcessor octaveChangedTo:sender.octave];
}

- (void)audioOutputChangedToNote:(NSString *)note
{
    self.keyNameLabel.text = note;
}

- (void)audioLevelUpdated:(float)averagePower {
    isBlowing = (averagePower > micSensitivity);
    
//    [self playSound];
}

- (IBAction)settingButtonAction:(id)sender {
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
