//
//  GAManualViewController.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 22..
//
//

#import "GAManualViewController.h"

@interface ContentsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ContentsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed:self.imageFileName];
}
@end

#pragma mark - GAManualViewController
@interface GAManualViewController () {
    NSArray *pageImages;
}

@end

@implementation GAManualViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageImages = @[@"4.png", @"1.png", @"2.png", @"3.png", @"5.png"];

    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    
    ContentsViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.view.frame = self.view.frame;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (ContentsViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (pageImages.count == 0 || index >= pageImages.count)
        return nil;
    
    ContentsViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentsViewController"];
    cvc.imageFileName = pageImages[index];
    cvc.pageIndex = index;
    
    return cvc;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ContentsViewController*)viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound))
        return nil;
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ContentsViewController*)viewController).pageIndex;
    
    if (index == NSNotFound)
        return nil;
    
    index++;
    if (index == pageImages.count)
        return nil;
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return pageImages.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
