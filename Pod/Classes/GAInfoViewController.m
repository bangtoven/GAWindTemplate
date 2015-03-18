//
//  GAInfoViewController.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 22..
//
//

#import "GAInfoViewController.h"

@interface GAInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@end

@implementation GAInfoViewController

- (IBAction)linkBarButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.catsnu.com"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoTextView.text = self.infoString;
}

@end
