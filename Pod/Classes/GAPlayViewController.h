//
//  ViewController.h
//  Hun
//
//  Created by 방정호 on 2014. 10. 31..
//  Copyright (c) 2014년 CAT@SNU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAButtonHole.h"

@interface GAPlayViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UILabel *keyNameLabel;

- (IBAction)holeButtonAction:(GAButtonHole *)sender;
- (IBAction)octaveButtonAction:(GAButtonHole *)sender;

@end

