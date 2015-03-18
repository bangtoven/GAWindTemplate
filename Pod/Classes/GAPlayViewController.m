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
#import "GAInfoViewController.h"

@interface GAPlayViewController () <UINavigationControllerDelegate, UIActionSheetDelegate,GAAudioOutputDelegate>

@property (weak, nonatomic) IBOutlet GAFingeringOctaveButton *octaveButton;
@property (weak, nonatomic) IBOutlet UIImageView *noteNameBackground;
@property (weak, nonatomic) IBOutlet UILabel *noteNameLabel;
@property (weak, nonatomic) IBOutlet JHGlowView *micGlowView;
@property (weak, nonatomic) IBOutlet UIImageView *blowImageView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@end

@implementation GAPlayViewController

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
//    NSString *model = [UIDevice currentDevice].model;
//    if ([model containsString:@"iPod"])
    return UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundView.image = [UIImage imageNamed:@"Background"];
    
    NSString *model = [UIDevice currentDevice].model;
    if ([model containsString:@"iPod"])
        self.navigationController.delegate = self;
    
    self.audioOutput = [[GAAudioOutputProcessor alloc] init];
    self.audioOutput.delegate = self;
    
    if (self.needsUpDownOctave) {
        [self.octaveButton setIsUpDown:YES];
        [GASettings sharedSetting].hasUpDownOctave = YES;
        [GASettings sharedSetting].baseNote += 12;
        [self.audioOutput updateSettings];
    }
    
    [self updateSettings];
    
    self.noteNameLabel.text = @"";
}

- (void)updateSettings
{
    GASettings *setting = [GASettings sharedSetting];
    self.blowImageView.hidden = setting.controlMode == GAControlModeTouch;
    
    self.noteNameLabel.hidden = !setting.displayNoteName;
    self.noteNameBackground.hidden = !setting.displayNoteName;
    
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

- (void)audioOutputNoteChanged:(NSString *)note
{
    self.noteNameLabel.text = note;
}

- (void)audioOutputVolumeChanged:(float)value
{
    self.micGlowView.value = value;
}

- (IBAction)settingButtonAction:(id)sender
{
    NSString *table = @"template";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:
                                  NSLocalizedStringFromTable(@"Cancel", table, @"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedStringFromTable(@"Settings", table, @"Settings"),
                                  NSLocalizedStringFromTable(@"Manual", table, @"Manual"),
                                  NSLocalizedStringFromTable(@"Inst", table, @"Inst"),
                                  NSLocalizedStringFromTable(@"App", table, @"App"),
                                  nil];
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
        case 2: {
            [self performSegueWithIdentifier:@"show info"
                                      sender:NSLocalizedString(@"inst-info", @"inst-info")];
            break;
        }
        case 3: {
            [self performSegueWithIdentifier:@"show info"
                                      sender:NSLocalizedStringFromTable(@"Developer", @"template", @"Developer")];
            break;
        }
        default:
            [self performSegueWithIdentifier:@"show info" sender:nil];
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show info"]) {
        [(GAInfoViewController*)segue.destinationViewController setInfoString:sender];
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
