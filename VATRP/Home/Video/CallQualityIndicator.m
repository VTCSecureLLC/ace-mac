//
//  CallQualityIndicator.m
//  ACE
//
//  Created by Norayr Harutyunyan on 2/5/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "CallQualityIndicator.h"

@interface CallQualityIndicator () {
    
}

@end


@implementation CallQualityIndicator

@synthesize callQuality = _callQuality;

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
    }
    
    return self;
}

- (void) setCallQuality:(int)callQuality_ {
    _callQuality = callQuality_;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.

    if (self.callQuality < 2) {
        NSDrawNinePartImage(dirtyRect,
                            [NSImage imageNamed:@"RTPquality_bad_leftTop"],
                            [NSImage imageNamed:@"RTPquality_bad_top"],
                            [NSImage imageNamed:@"RTPquality_bad_rightTop"],
                            [NSImage imageNamed:@"RTPquality_bad_left"],
                            nil,
                            [NSImage imageNamed:@"RTPquality_bad_right"],
                            [NSImage imageNamed:@"RTPquality_bad_leftBottom"],
                            [NSImage imageNamed:@"RTPquality_bad_bottom"],
                            [NSImage imageNamed:@"RTPquality_bad_rightBottom"],
                            NSCompositeSourceIn,
                            1.0,
                            NO);
    } else if (self.callQuality < 3) {
        NSDrawNinePartImage(dirtyRect,
                            [NSImage imageNamed:@"RTPquality_medium_leftTop"],
                            [NSImage imageNamed:@"RTPquality_medium_top"],
                            [NSImage imageNamed:@"RTPquality_medium_rightTop"],
                            [NSImage imageNamed:@"RTPquality_medium_left"],
                            nil,
                            [NSImage imageNamed:@"RTPquality_medium_right"],
                            [NSImage imageNamed:@"RTPquality_medium_leftBottom"],
                            [NSImage imageNamed:@"RTPquality_medium_bottom"],
                            [NSImage imageNamed:@"RTPquality_medium_rightBottom"],
                            NSCompositeSourceIn,
                            1.0,
                            NO);
    }
}

@end
