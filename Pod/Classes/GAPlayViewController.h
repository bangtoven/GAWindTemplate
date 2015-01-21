//
//  ViewController.h
//  Hun
//
//  Created by 방정호 on 2014. 10. 31..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAButtonHole.h"
#import "GAButtonOctave.h"

@interface GAPlayViewController : UIViewController 

@property (nonatomic) BOOL needs3Octave;

@property (weak, nonatomic) IBOutlet GAButtonOctave *octaveButton;
@property (weak, nonatomic) IBOutlet UILabel *keyNameLabel;

- (IBAction)holeButtonAction:(GAButtonHole *)sender;
- (IBAction)octaveButtonAction:(GAButtonOctave *)sender;

@end

