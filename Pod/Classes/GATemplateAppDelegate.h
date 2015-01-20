//
//  GAAppDelegate.h
//  GAWindTemplate
//
//  Created by CocoaPods on 01/20/2015.
//  Copyright (c) 2014 Jungho Bang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAPlayViewController.h"

@interface GATemplateAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)initialize:(GAPlayViewController*)pvc;

@end
