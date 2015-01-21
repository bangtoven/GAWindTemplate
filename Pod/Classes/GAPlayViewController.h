//
//  ViewController.h
//  Hun
//
//  Created by 방정호 on 2014. 10. 31..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAFingeringHoleButton.h"
#import "GAFingeringOctaveButton.h"

@interface GAPlayViewController : UIViewController 

@property (nonatomic) BOOL needsUpDownOctave;

@property (weak, nonatomic) IBOutlet GAFingeringOctaveButton *octaveButton;
@property (weak, nonatomic) IBOutlet UILabel *keyNameLabel;

- (IBAction)holeButtonAction:(GAFingeringHoleButton *)sender;
- (IBAction)octaveButtonAction:(GAFingeringOctaveButton *)sender;

@end

