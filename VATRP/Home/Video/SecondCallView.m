//
//  SecondCallView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/27/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SecondCallView.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@interface SecondCallView () {
    NSRect selfOriginFrame;
}

@property (weak) IBOutlet BackgroundedView *viewAlphed;
@property (weak) IBOutlet NSTextField *labelDisplayName;

@property (weak) IBOutlet NSButton *buttonAnswer;
@property (weak) IBOutlet NSButton *buttonDecline;

@end

@implementation SecondCallView

@synthesize call;

- (void) awakeFromNib {
    [super awakeFromNib];
    
//    self.wantsLayer = YES;
//    [self setBackgroundColor:[NSColor redColor]];
    
    self.viewAlphed.wantsLayer = YES;
    [self.viewAlphed setBackgroundColor:[NSColor grayColor]];
    [self.viewAlphed setAlphaValue:0.3];
    [self setBackgroundColor:[NSColor clearColor]];
    
    self.buttonAnswer.wantsLayer = YES;
    self.buttonDecline.wantsLayer = YES;
    
    [self.buttonAnswer.layer setBackgroundColor:[NSColor greenColor].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonAnswer];
    [self.buttonDecline.layer setBackgroundColor:[NSColor redColor].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDecline];
    
    self.labelDisplayName.wantsLayer = YES;
    selfOriginFrame = self.frame;
}

#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    call = acall;
    [self update];
}

- (IBAction)onButtonAnswer:(id)sender {
    [[CallService sharedInstance] accept:self.call];
    [self setHidden:YES];
}

- (IBAction)onButtonDecline:(id)sender {
    [[CallService sharedInstance] decline:self.call];
    [self setHidden:YES];
}

- (void)update {
    NSString *address;
    
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);
    if (addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        if(useLinphoneAddress) {
            const char* lUserName = linphone_address_get_username(addr);
            if(lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    
    // Set Address
    if(address == nil) {
        address = @"Unknown";
    }
    
    self.labelDisplayName.stringValue = address;
}

- (void) shakeWindow {
    self.frame = selfOriginFrame;

    static int numberOfShakes = 3;
    static float durationOfShake = 0.5f;
    static float vigourOfShake = 0.05f;
    
    CGRect frame = [self frame];
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
    
    for (NSInteger index = 0; index < numberOfShakes; index++){
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
    }
    
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    
    [self setAnimations:[NSDictionary dictionaryWithObject: shakeAnimation forKey:@"frameOrigin"]];
    [[self animator] setFrameOrigin:NSMakePoint(frame.origin.x + 1, frame.origin.y)];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self shakeWindow];
}

@end
