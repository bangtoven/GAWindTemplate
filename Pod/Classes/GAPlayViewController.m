//
//  ViewController.m
//  Hun
//
//  Created by 방정호 on 2014. 10. 31..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import "GAPlayViewController.h"

@interface GAPlayViewController () <UIActionSheetDelegate,GAAudioOutputDelegate>

@property (weak, nonatomic) IBOutlet GAFingeringOctaveButton *octaveButton;
@property (weak, nonatomic) IBOutlet UILabel *keyNameLabel;
@property (strong, nonatomic) GAFingeringProcessor* fingeringProcessor;

@end

@implementation GAPlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.audioOutput = [GAAudioOutputProcessor sharedOutput];
    self.audioOutput.delegate = self;
    
    self.fingeringProcessor = [GAFingeringProcessor new];
    self.fingeringProcessor.delegate = self.audioOutput;
    
    if (self.needsUpDownOctave) {
        [self.octaveButton setIsUpDown:YES];
        [self.audioOutput makeOneOctaveHigher];
    }
    
    //    micSensitivity = [GABlowProcessor micSensitivity];
    //    blowProcessor = [[GABlowProcessor alloc] init];
    //    blowProcessor.delegate = self;
    //    [blowProcessor startUpdate];

    self.keyNameLabel.text = @"";
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
    [self.fingeringProcessor keyHoleInLocation:(int)sender.location changedTo:sender.closed];
}

- (IBAction)octaveButtonAction:(GAFingeringOctaveButton *)sender {
    [self.fingeringProcessor octaveChangedTo:sender.octave];
}

- (void)audioOutputChangedToNote:(NSString *)note
{
    self.keyNameLabel.text = note;
}

- (IBAction)settingButtonAction:(id)sender
{
    [self.audioOutput stopPlaying];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"설정",@"사용법",@"악기 정보",@"앱 정보",nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;

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
        [self.audioOutput updateSettings];
    }
}

@end
