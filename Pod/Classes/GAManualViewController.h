//
//  GAManualViewController.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 22..
//
//

#import <UIKit/UIKit.h>

@interface ContentsViewController : UIViewController
@property NSUInteger pageIndex;
@property NSString *imageFileName;
@end

@interface GAManualViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end


