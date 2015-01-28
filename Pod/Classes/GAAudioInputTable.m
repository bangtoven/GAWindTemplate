//
//  GAAudioInputTable.m
//  Pods
//
//  Created by Jungho Bang on 2015. 1. 28..
//
//

#import "GAAudioInputTable.h"

@interface GAAudioInputTable ()
@property (strong) NSArray *sampleTable;
@end

@implementation GAAudioInputTable

- (instancetype)initWithContentsOfFile:(NSString *)path
{
    if (self = [super init]) {
        self.sampleTable = [NSArray arrayWithContentsOfFile:path];
        int first = [self.sampleTable[0][@"midiNumber"] intValue];
        self.range = NSMakeRange(first, self.sampleTable.count);
    }
    return self;
}

- (instancetype)init
{
    return [self initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioInputTable" ofType:@"plist"]];
}

- (GAAudioInputFile*)audioInputOfNote:(int)note
{
    int first = (int)self.range.location;
    int last = (int)NSMaxRange(self.range);
    
    int index;
    int pitchShift = 0;
    if (NSLocationInRange(note, self.range))
        index = note-first;
    else if (note >= last) {
        index = last-first-1;
        pitchShift = note-(last-1);
    }
    else {
        index = 0;
        pitchShift = note-first;
    }

    NSDictionary *sampleInfo = self.sampleTable[index];
    NSString *fileName = sampleInfo[@"fileName"];
    int pitch = [sampleInfo[@"pitch"] intValue] + pitchShift;
    
    GAAudioInputFile *input = [[GAAudioInputFile alloc] initWithFileName:fileName andPitch:pitch];
    input.noteName = [GAAudioInputTable nameOfNote:note];
    input.midiNumber = note;
    
    return input;
}

+ (NSString*)nameOfNote:(int)note
{
    NSArray *noteNameArray = @[@"C",@"Db",@"D",@"Eb",@"E",@"F",@"Gb",@"G",@"Ab",@"A",@"Bb",@"B"];
    int octave = note/12 - 2;
    int index = note%12;
    return [NSString stringWithFormat:@"%@%d",noteNameArray[index],octave];
}

@end
