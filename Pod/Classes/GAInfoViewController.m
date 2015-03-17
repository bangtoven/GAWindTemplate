//
//  GAInfoViewController.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 22..
//
//

#import "GAInfoViewController.h"

@interface GAInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation GAInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoLabel.numberOfLines = 0;
    [self.infoLabel sizeToFit];
}

@end
