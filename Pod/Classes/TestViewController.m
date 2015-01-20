//
//  TestViewController.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 20..
//
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

+ (instancetype)tvcWithNib
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GAWindTemplate" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
//    [bundle load];
    
    TestViewController *tvc = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:bundle];
    
    return tvc;
}

-(id)init {
    if (self=[super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
