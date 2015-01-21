//
//  NSBundle+GATemplate.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 21..
//
//

#import "NSBundle+GATemplate.h"

@implementation NSBundle (GATemplate)

+(NSBundle*)templateBundle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GAWindTemplate" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
}

@end
