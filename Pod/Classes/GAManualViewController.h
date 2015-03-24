//
//  GAManualViewController.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 22..
//
//

#import <UIKit/UIKit.h>

@interface GAManualViewController : UIViewController <UIPageViewControllerDataSource>
{
    NSArray *pageImages;
}
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (void)pageDidChanged:(NSUInteger)pageIndex;
@end

@interface ContentsViewController : UIViewController
@property NSUInteger pageIndex;
@property NSString *imageFileName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) GAManualViewController *masterViewController;
@end