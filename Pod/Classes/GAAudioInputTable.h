//
//  GAAudioInputTable.h
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 28..
//
//

#import <Foundation/Foundation.h>
#import "GAAudioInputFile.h"

@interface GAAudioInputTable : NSObject

+ (NSString*)nameOfNote:(int)note;

@property (nonatomic) NSRange range;

- (instancetype)initWithContentsOfFile:(NSString *)path;
- (instancetype)init; // init with default path (AudioInputTable.plist in main bundle)
- (GAAudioInputFile*)audioInputOfNote:(int)note;

@end
