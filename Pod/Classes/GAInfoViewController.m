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
    if (self.activateWhoIsTheDeveloper) {
        count++;
        if (count<10)
            self.infoTextView.textColor = [UIColor colorWithHue:(10-count)/10. saturation:count/10. brightness:1.0 alpha:1.0];
        else if (count==10) {
            self.infoTextView.textColor = [UIColor whiteColor];
            self.infoTextView.text =
            NSLocalizedStringFromTable(@"Developer", @"template", @"Developer");
        }
        else if (count==11) {
            self.infoTextView.text = self.infoString;
            count = 0;
        }
        else
            return;
    }
}

@end
