//
//  VideoView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "VideoView.h"
#import "VideoCallViewController.h"
#import "SettingsWindowController.h"
#import "KeypadWindowController.h"
#import "ChatWindowController.h"
#import "CallControllersView.h"
#import "NumpadView.h"
#import "SecondIncomingCallView.h"
#import "SecondCallView.h"
#import <QuartzCore/QuartzCore.h>
#import "CallService.h"
#import "SettingsService.h"
#import "ChatService.h"
#import "AppDelegate.h"
#import "Utils.h"


@interface VideoView () <CallControllersViewDelegate> {
    NSTimer *timerCallDuration;
    NSTimer *timerRingCount;
    
    KeypadWindowController *keypadWindowController;
    
    NSString *windowTitle, *address;
}

@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallState;

@property (weak) IBOutlet BackgroundedView *callControllsConteinerView;
@property (weak) IBOutlet CallControllersView *callControllersView;
@property (weak) IBOutlet NumpadView *numpadView;
@property (weak) IBOutlet SecondIncomingCallView *secondIncomingCallView;
@property (weak) IBOutlet SecondCallView *secondCallView;

@property (weak) IBOutlet NSTextField *labelRingCount;

@property (weak) IBOutlet NSImageView *callAlertImageView;
@property (weak) IBOutlet NSView *localVideo;


- (void) inCallTick:(NSTimer*)timer;

@end

@implementation VideoView

@synthesize call;

- (void) awakeFromNib {
    [super awakeFromNib];
    
    windowTitle  = @"Call with %@ duration: %@";
    address = @"";
    
    timerCallDuration = nil;
    
    self.wantsLayer = YES;
    self.remoteVideoView.wantsLayer = YES;
    self.labelDisplayName.wantsLayer = YES;
    self.labelCallState.wantsLayer = YES;
    [self.callControllsConteinerView setBackgroundColor:[NSColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
//    self.labelDisplayName.hidden = YES;
    
    self.callControllersView.delegate = self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onButtonKeypad:(id)sender {
    keypadWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"KeypadWindowController"];
    [keypadWindowController showWindow:self];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:acall state:astate];
}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
    if(call == acall && (astate == LinphoneCallEnd || astate == LinphoneCallError)) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
    }
    
    LinphoneCore *lc = [LinphoneManager getLc];
    
    switch (astate) {
        case LinphoneCallIncomingReceived: {
            self.labelCallState.stringValue = @"Incoming Call 00:00";
            [self startRingCountTimerWithTimeInterval:3.75];
            
            [self startCallFlashingAnimation];
            
            [self.callControllsConteinerView setHidden:NO];
        }
        case LinphoneCallIncomingEarlyMedia:
        {
            break;
        }
        case LinphoneCallConnected: {
            [self.callControllersView setCall:acall];

            [self stopCallFlashingAnimation];
            
            [self stopRingCountTimer];
            
            linphone_core_set_native_video_window_id(lc, (__bridge void *)(self));
            
            [[AppDelegate sharedInstance].viewController showVideoMailWindow];
            
            if ([SettingsService getShowPreview]) {
                self.localVideo.hidden = NO;
                linphone_core_use_preview_window(lc, YES);
                linphone_core_set_native_preview_window_id(lc, (__bridge void *)(self.localVideo));
            } else {
                self.localVideo.hidden = YES;
            }
            
            timerCallDuration = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(inCallTick:)
                                                               userInfo:nil
                                                                repeats:YES];
            
            self.labelCallState.stringValue = @"Connected 00:00";
            
            [self.localVideo setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
            [[self.localVideo animator] setFrame:NSMakeRect(524, 580, 176, 99)];

            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAllCallControllers) object:nil];
            [self performSelector:@selector(hideAllCallControllers) withObject:nil afterDelay:3.0];
        }
            break;
        case LinphoneCallOutgoingInit: {
            self.labelCallState.stringValue = @"Calling 00:00";
            [self.callControllsConteinerView setHidden:NO];
        }
            break;
        case LinphoneCallOutgoingRinging: {

            self.labelCallState.stringValue = @"Ringing 00:00";
            
            [self startRingCountTimerWithTimeInterval:3.6];
        }
            break;
        case LinphoneCallPaused: {
            int call_Duration = linphone_call_get_duration(acall);
            NSString *string_time = [Utils getTimeStringFromSeconds:call_Duration];
            self.labelCallState.stringValue = [NSString stringWithFormat:@"On Hold %@",string_time];
        }
            break;
        case LinphoneCallStreamsRunning:
        {
            //            [self changeCurrentView:[InCallViewController compositeViewDescription]];
            break;
        }
        case LinphoneCallError:
        {
            [self stopRingCountTimer];
            [self stopCallFlashingAnimation];
            [self displayCallError:call message:@"Call Error"];
            self.numpadView.hidden = YES;
            self.call = nil;

            break;
        }
        case LinphoneCallEnd:
        {
            linphone_core_enable_video_preview(lc, FALSE);
            linphone_core_use_preview_window(lc, FALSE);
            linphone_core_enable_self_view([LinphoneManager getLc], FALSE);

            self.call = nil;
            self.numpadView.hidden = YES;
            [self stopRingCountTimer];
            [self stopCallFlashingAnimation];
            
            if([AppDelegate sharedInstance].viewController.videoMailWindowController.isShow){
                [[AppDelegate sharedInstance].viewController.videoMailWindowController close];
            }
            break;
        }
        default:
            break;
    }
}

- (void)displayCallError:(LinphoneCall *)call_ message:(NSString *)message {
    const char *lUserNameChars = linphone_address_get_username(linphone_call_get_remote_address(call_));
    NSString *lUserName =
    lUserNameChars ? [[NSString alloc] initWithUTF8String:lUserNameChars] : NSLocalizedString(@"Unknown", nil);
    NSString *lMessage;
    NSString *lTitle;
    
    // get default proxy
    LinphoneProxyConfig *proxyCfg;
    linphone_core_get_default_proxy([LinphoneManager getLc], &proxyCfg);
    if (proxyCfg == nil) {
        lMessage = NSLocalizedString(@"Please make sure your device is connected to the internet and double check your "
                                     @"SIP account configuration in the settings.",
                                     nil);
    } else {
        lMessage = [NSString stringWithFormat:NSLocalizedString(@"Cannot call %@.", nil), lUserName];
    }
    
    switch (linphone_call_get_reason(call_)) {
        case LinphoneReasonNotFound:
            lMessage = [NSString stringWithFormat:NSLocalizedString(@"%@ is not registered.", nil), lUserName];
            break;
        case LinphoneReasonBusy:
            lMessage = [NSString stringWithFormat:NSLocalizedString(@"%@ is busy.", nil), lUserName];
            break;
        default:
            if (message != nil) {
                lMessage = [NSString stringWithFormat:NSLocalizedString(@"%@\nReason was: %@", nil), lMessage, message];
            }
            break;
    }
    
    lTitle = NSLocalizedString(@"Call failed", nil);
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:lTitle];
    [alert setInformativeText:lMessage];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert runModal];
}

- (void)dismiss {
    VideoCallWindowController *videoCallWindowController = [[AppDelegate sharedInstance] getVideoCallWindow];
    [videoCallWindowController close];
    
    [self.callControllersView dismisCallInfoWindow];
    
    [[[CallService sharedInstance] getCallWindowController] close];
    
    if (timerCallDuration && [timerCallDuration isValid]) {
        [timerCallDuration invalidate];
        timerCallDuration = nil;
    }
}

- (void)update {
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);
    if (addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
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
    //update caller address in window title
    [[[CallService sharedInstance] getCallWindowController].window setTitle:[NSString stringWithFormat:windowTitle, address, [Utils getTimeStringFromSeconds:0]]];
}

#pragma mark - CallControllersView Delegate

- (void) didClickCallControllersViewNumpad:(CallControllersView*)callControllersView_ {
    self.numpadView.hidden = !self.numpadView.hidden;
}


#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    call = acall;
    
    if (call) {
        [self update];
        [self.callControllersView setCall:call];
    }
}

- (void)setIncomingCall:(LinphoneCall*)acall {
    call = acall;
    [self update];
    [self callUpdate:call state:linphone_call_get_state(call)];
    
    [self.callControllersView setIncomingCall:acall];
}

- (void)setOutgoingCall:(LinphoneCall*)acall {
    if(acall != NULL){
        call = acall;
        [self update];
    
        [self.callControllersView setOutgoingCall:acall];
    }
    else{
        
    }
}

- (void)showSecondIncomingCallView:(LinphoneCall *)aCall {
    [self.secondIncomingCallView setCall:aCall];
    [self.secondIncomingCallView setHidden:NO];
}

- (void)hideSecondIncomingCallView {
    [self.secondIncomingCallView setHidden:YES];
}

- (void)setCallToSecondCallView:(LinphoneCall*)aCall {
    [self.secondCallView setCall:aCall];
}

- (void)hideSecondCallView {
    [self.secondCallView setCall:nil];
    [self.secondCallView setHidden:YES];
}

- (void) inCallTick:(NSTimer*)timer {
    if (call) {
        int call_Duration = linphone_call_get_duration(call);
        NSString *string_time = [Utils getTimeStringFromSeconds:call_Duration];

        LinphoneCallState call_state = linphone_call_get_state(call);
        
        switch (call_state) {
            case LinphoneCallConnected:
            case LinphoneCallStreamsRunning:
            {
                self.labelCallState.stringValue = [NSString stringWithFormat:@"Connected %@", string_time];
            }
                break;
            case LinphoneCallPaused:
            case LinphoneCallPausedByRemote:
            {
                self.labelCallState.stringValue = [NSString stringWithFormat:@"On Hold %@", string_time];
            }
                break;
                
            default:
                break;
        }
        
        [[[CallService sharedInstance] getCallWindowController].window setTitle:[NSString stringWithFormat:windowTitle, address, string_time]];
    }
}

- (void)startRingCountTimerWithTimeInterval:(NSTimeInterval)time {
    [self stopRingCountTimer];
    
    self.labelRingCount.hidden = NO;
    [self ringCountTimer];
    timerRingCount = [NSTimer scheduledTimerWithTimeInterval:time
                                                      target:self
                                                    selector:@selector(ringCountTimer)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopRingCountTimer {
    if (timerRingCount && [timerRingCount isValid]) {
        [timerRingCount invalidate];
        timerRingCount = nil;
    }
    
    self.labelRingCount.hidden = YES;
    self.labelRingCount.intValue = 0;
}

- (void)ringCountTimer {
    self.labelRingCount.stringValue = [@(self.labelRingCount.intValue + 1) stringValue];
}

- (void) startCallFlashingAnimation {
    NSView *content = self;
    CALayer *layer = [content layer];
    
    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anime.fromValue = (id)[layer backgroundColor];
    anime.toValue = (id)CFBridgingRelease(CGColorCreateGenericRGB(0.8, 0.1, 0.1, 1.0));
    anime.duration = 0.3f;
    anime.autoreverses = YES;
    anime.repeatCount = 100;
    
    [layer addAnimation:anime forKey:@"backgroundColor"];
}

- (void) stopCallFlashingAnimation {
    NSView *content = self;
    CALayer *layer = [content layer];
    [layer removeAllAnimations];
}

- (void)setMouseInCallWindow {
    [self.callControllsConteinerView setHidden:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAllCallControllers) object:nil];
    [self performSelector:@selector(hideAllCallControllers) withObject:nil afterDelay:3.0];
}

- (void) hideAllCallControllers {
    [self.callControllsConteinerView setHidden:YES];
}

- (void)showVideoPreview {
    if ([SettingsService getShowPreview]) {
        LinphoneCore *lc = [LinphoneManager getLc];
        const char *cam = linphone_core_get_video_device(lc);
        linphone_core_set_video_device(lc, cam);
        linphone_core_enable_video_preview([LinphoneManager getLc], TRUE);
        linphone_core_use_preview_window(lc, YES);
        linphone_core_set_native_preview_window_id(lc, (__bridge void *)(self));
        linphone_core_enable_self_view([LinphoneManager getLc], TRUE);
     } else {
        self.localVideo.hidden = YES;
    }
}

@end
