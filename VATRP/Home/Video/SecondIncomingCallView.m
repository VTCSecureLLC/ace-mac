//
//  SecondIncomingCallView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/27/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SecondIncomingCallView.h"
#import <QuartzCore/QuartzCore.h>
#import "ContactPictureManager.h"
#import "Utils.h"
#import "BackgroundedView.h"

@interface SecondIncomingCallView () {
    NSRect selfOriginFrame;
}

@property (weak) IBOutlet BackgroundedView *viewAlphed;
@property (weak) IBOutlet NSTextField *labelDisplayName;

@property (weak) IBOutlet NSButton *buttonEndAnswer;
@property (weak) IBOutlet NSButton *buttonHoldAnswer;
@property (weak) IBOutlet NSButton *buttonDecline;

@property (weak) IBOutlet NSImageView *callerImageView;

@end

@implementation SecondIncomingCallView

@synthesize call;

-(id) init
{
    self = [super initWithNibName:@"SecondIncomingCallView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
//    self.wantsLayer = YES;
//    [self setBackgroundColor:[NSColor redColor]];
    
    self.viewAlphed.wantsLayer = YES;
    [self.viewAlphed setBackgroundColor:[NSColor grayColor]];
    [self.viewAlphed setAlphaValue:0.3];
    [self setBackgroundColor:[NSColor clearColor]];
    
    self.buttonEndAnswer.wantsLayer = YES;
    self.buttonHoldAnswer.wantsLayer = YES;
    self.buttonDecline.wantsLayer = YES;
    
    [self.buttonEndAnswer.layer setBackgroundColor:[NSColor greenColor].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonEndAnswer];
    [self.buttonHoldAnswer.layer setBackgroundColor:[NSColor greenColor].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonHoldAnswer];
    [self.buttonDecline.layer setBackgroundColor:[NSColor redColor].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDecline];
    
    self.labelDisplayName.wantsLayer = YES;
    selfOriginFrame = self.view.frame;
}

#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    LinphoneCore *lc = [LinphoneManager getLc];
    if(lc){
        if(linphone_core_get_calls_nb(lc) > 2){
            if(acall){
                linphone_core_decline_call(lc, acall, LinphoneReasonBusy);
            }
        }
    }
    call = acall;
    [self update];
}

- (IBAction)onButtonEndAnswer:(id)sender {
    [[CallService sharedInstance] decline:[[CallService sharedInstance] getCurrentCall]];
    [[CallService sharedInstance] accept:self.call];
    [self setHidden:YES];
}

- (IBAction)onButtonHoldAnswer:(id)sender {
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
    char * remoteAddress = linphone_call_get_remote_address_as_string(call);
    NSString  *sipURI = [NSString stringWithUTF8String:remoteAddress];
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
    
    //NSString *provider  = [Utils providerNameFromSipURI:sipURI];
    NSImage *contactImage = [[NSImage alloc]initWithContentsOfFile:[[ContactPictureManager sharedInstance] imagePathByName:address andSipURI:sipURI]];
    if (contactImage) {
        [self.callerImageView setWantsLayer: YES];
        self.callerImageView.layer.borderWidth = 1.0;
        self.callerImageView.layer.cornerRadius = self.callerImageView.frame.size.height / 2 ;
        self.callerImageView.layer.masksToBounds = YES;
        [self.callerImageView setImage:contactImage];
    } else {
        [self.callerImageView setImage:[NSImage imageNamed:@"male"]];
    }
    
    self.labelDisplayName.stringValue = address;
}

- (void) shakeWindow {
    self.view.frame = selfOriginFrame;

    static int numberOfShakes = 3;
    static float durationOfShake = 0.5f;
    static float vigourOfShake = 0.05f;
    
    CGRect frame = [self getFrame];
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
    
    [self.view setAnimations:[NSDictionary dictionaryWithObject: shakeAnimation forKey:@"frameOrigin"]];
    [[self.view animator] setFrameOrigin:NSMakePoint(frame.origin.x + 1, frame.origin.y)];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self shakeWindow];
}

- (void) reorderControllersForFrame:(NSRect)frame {
    [[self.viewAlphed animator] setFrame:NSMakeRect(frame.size.width/2 - self.viewAlphed.frame.size.width/2, 302, self.viewAlphed.frame.size.width, self.viewAlphed.frame.size.height)];
    [[self.labelDisplayName animator] setFrame:NSMakeRect(frame.size.width/2 - self.labelDisplayName.frame.size.width/2, 488, self.labelDisplayName.frame.size.width, self.labelDisplayName.frame.size.height + 50)];
    [[self.buttonEndAnswer animator] setFrame:NSMakeRect(frame.size.width/2 - 244, 394, self.buttonEndAnswer.frame.size.width, self.buttonEndAnswer.frame.size.height)];
    [[self.buttonHoldAnswer animator] setFrame:NSMakeRect(frame.size.width/2 + 14, 394, self.buttonHoldAnswer.frame.size.width, self.buttonHoldAnswer.frame.size.height)];
    [[self.buttonDecline animator] setFrame:NSMakeRect(frame.size.width/2 - self.buttonDecline.frame.size.width/2, 317, self.buttonDecline.frame.size.width, self.buttonDecline.frame.size.height)];
}

@end
