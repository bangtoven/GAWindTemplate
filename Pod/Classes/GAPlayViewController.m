//
//  ViewController.m
//  Hun
//
//  Created by 방정호 on 2014. 10. 31..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAPlayViewController.h"
#import "JHGlowView.h"
#import "GASettings.h"

@interface GAPlayViewController () <UINavigationControllerDelegate, UIActionSheetDelegate,GAAudioOutputDelegate>

@property (weak, nonatomic) IBOutlet GAFingeringOctaveButton *octaveButton;
@property (weak, nonatomic) IBOutlet UILabel *noteNameLabel;
@property (weak, nonatomic) IBOutlet JHGlowView *micGlowView;
@property (weak, nonatomic) IBOutlet UIImageView *blowImageView;

@end

@implementation GAPlayViewController

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    NSString *model = [UIDevice currentDevice].model;
    if ([model containsString:@"iPod"])
        return UIInterfaceOrientationMaskPortraitUpsideDown;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate = self;
    
    self.audioOutput = [[GAAudioOutputProcessor alloc] init];
    self.audioOutput.delegate = self;
    
    if (self.needsUpDownOctave) {
        [self.octaveButton setIsUpDown:YES];
        [GASettings sharedSetting].baseNote += 12;
        [self.audioOutput updateSettings];
    }
    
    [self updateSettings];
    
    self.noteNameLabel.text = @"";
}

- (void)updateSettings
{
    self.blowImageView.hidden = [GASettings sharedSetting].isTouchMode;
    self.micGlowView.value = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)holeButtonAction:(GAFingeringHoleButton *)sender {
    [self.audioOutput.fingeringProcessor keyHoleInLocation:(int)sender.location changedTo:sender.closed];
}

- (IBAction)octaveButtonAction:(GAFingeringOctaveButton *)sender {
    [self.audioOutput.fingeringProcessor octaveChangedTo:sender.octave];
}

- (void)audioOutputStopped
{
//    self.noteNameLabel.text = @"";
    self.micGlowView.value = 0;
}

- (void)audioOutputChangedToNote:(NSString *)note
{
    self.noteNameLabel.text = note;
}

- (void)audioOutputChangedWithMicLevel:(float)value
{
    self.micGlowView.value = value;
}

- (IBAction)settingButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"설정",@"사용법",@"악기 정보",@"앱 정보",nil];
    [actionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;

    [self.audioOutput stopAudioOutput];

    switch (buttonIndex) {
        case 0: 
            [self performSegueWithIdentifier:@"show settings" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"show manual" sender:nil];
            break;
        default:
            [self performSegueWithIdentifier:@"show info" sender:nil];
            break;
    }
}

- (IBAction)backToPlayView:(UIStoryboardSegue*)sender
{
    if ([sender.identifier isEqualToString:@"settings updated"]) {
        [self updateSettings];
        [self.audioOutput updateSettings];
    }
}

@end
