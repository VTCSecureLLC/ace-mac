//
//  SecondCallView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/2/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SecondCallView.h"
#import "Utils.h"
#import "BackgroundedView.h"

@interface SecondCallView () {
    NSTimer *timerCallDuration;
}

@property (weak) IBOutlet BackgroundedView *viewAlphaed;
@property (weak) IBOutlet NSButton *buttonHangup;
@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallDuration;
@property (weak) IBOutlet NSTextField *labelCallState;

@end


@implementation SecondCallView

@synthesize call;

-(id) init
{
    self = [super initWithNibName:@"SecondCallView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.view.wantsLayer = YES;
    [self setBackgroundColor:[NSColor clearColor]];
    
    self.viewAlphaed.wantsLayer = YES;
    [self.viewAlphaed setBackgroundColor:[NSColor colorWithRed:82.0/255.0 green:105.0/255.0 blue:117.0/255.0 alpha:1.0]];
    [self.viewAlphaed setAlphaValue:0.7];
    [self setBackgroundColor:[NSColor clearColor]];
    
    self.buttonHangup.wantsLayer = YES;
    
    [self.buttonHangup.layer setBackgroundColor:[NSColor colorWithRed:190.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1.0].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonHangup];
    
    self.labelDisplayName.wantsLayer = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)onButtonSwap:(id)sender {
    [[CallService sharedInstance] swapCallsToCall:self.call];
}

- (IBAction)onButtonHangup:(id)sender {
    [[CallService sharedInstance] decline:self.call];
}

#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    call = acall;
    
    if (call) {
        [self update];
        [self setHidden:NO];
        
        [self startCallDurationTimer];
    }
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:acall state:astate];
}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
    if (!self.call || self.call != acall) {
        return;
    }

    switch (astate) {
        case LinphoneCallError:
        case LinphoneCallEnd:
        {
            self.call = nil;
            [self setHidden:YES];
            [self stopCallDurationTimer];
        }
            break;
        default:
            break;
    }
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

- (void) inCallTick:(NSTimer*)timer {
    if (self.call) {
        int call_Duration = linphone_call_get_duration(self.call);
        self.labelCallDuration.stringValue = [Utils getTimeStringFromSeconds:call_Duration];
        
        LinphoneCallState call_state = linphone_call_get_state(self.call);
        
        switch (call_state) {
            case LinphoneCallConnected:
            case LinphoneCallStreamsRunning:
            {
//                self.labelCallState.stringValue = [NSString stringWithFormat:@"Connected %@",string_time];
            }
                break;
            case LinphoneCallPaused:
            case LinphoneCallPausedByRemote:
            {
//                self.labelCallState.stringValue = [NSString stringWithFormat:@"On Hold %@",string_time];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void) startCallDurationTimer {
    [self stopCallDurationTimer];
    
    timerCallDuration = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                         target:self
                                                       selector:@selector(inCallTick:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void) stopCallDurationTimer {
    if (timerCallDuration && [timerCallDuration isValid]) {
        [timerCallDuration invalidate];
        timerCallDuration = nil;
    }
}

@end
