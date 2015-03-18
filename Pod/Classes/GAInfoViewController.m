//
//  GAInfoViewController.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 22..
//
//

#import "GAInfoViewController.h"

@interface GAInfoViewController () {
    int count;
}
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

- (IBAction)whoIsTheDeveloper:(id)sender {
    count++;
    if (count<3)
        return;
    else if (count<10)
        self.infoTextView.textColor = [UIColor colorWithWhite:1.0 alpha:(12-count)/10.];
    else if (count==10) {
        self.infoTextView.textColor = [UIColor whiteColor];
        self.infoTextView.text =
        @"by Jungho Bang (me@bangtoven.com)";
    }
    else if (count==11)
        self.infoTextView.text = self.infoString;
    else
        return;
}

@end
