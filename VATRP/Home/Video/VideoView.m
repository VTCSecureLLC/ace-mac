//
//  VideoView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "VideoView.h"
#import "VideoCallViewController.h"
#import "CallInfoWindowController.h"
#import "SettingsWindowController.h"
#import "KeypadWindowController.h"
#import "ChatWindowController.h"
#import "CallControllersView.h"
#import "NumpadView.h"
#import <QuartzCore/QuartzCore.h>
#import "CallService.h"
#import "ChatService.h"
#import "AppDelegate.h"


@interface VideoView () <CallControllersViewDelegate> {
    NSTimer *timerCallDuration;
    NSTimer *timerRingCount;
    NSTimeInterval startCallTime;
    
    CallInfoWindowController *callInfoWindowController;
    KeypadWindowController *keypadWindowController;
    
    NSString *windowTitle, *address;
}

@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallDuration;
@property (weak) IBOutlet NSTextField *labelCallState;

@property (weak) IBOutlet CallControllersView *callControllersView;
@property (weak) IBOutlet NumpadView *numpadView;

@property (weak) IBOutlet NSTextField *ringCountLabel;

@property (weak) IBOutlet NSImageView *callAlertImageView;
@property (weak) IBOutlet NSView *localVideo;


- (IBAction)onButtonAnswer:(id)sender;
- (IBAction)onButtonDecline:(id)sender;
- (IBAction)onButtonCallInfo:(id)sender;
- (IBAction)onButtonKeypad:(id)sender;
- (IBAction)onButtonOpenMessage:(id)sender;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
    self.labelCallDuration.hidden = YES; //hiding this for now because of new remote view
//    self.labelDisplayName.hidden = YES;
    
    self.callControllersView.delegate = self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCallUpdate
                                                  object:nil];
}

- (IBAction)onButtonCallInfo:(id)sender {
    callInfoWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"CallInfo"];
    [callInfoWindowController showWindow:self];
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
            [self startRingCountTimer];
            
//            [self startCallFlashingAnimation];
        }
        case LinphoneCallIncomingEarlyMedia:
        {
            break;
        }
        case LinphoneCallConnected: {
            [self stopCallFlashingAnimation];
            
            [self stopRingCountTimer];
            
            linphone_core_set_native_video_window_id(lc, (__bridge void *)(self));
            
            [[AppDelegate sharedInstance].viewController showVideoMailWindow];
            linphone_core_use_preview_window(lc, YES);
            linphone_core_set_native_preview_window_id(lc, (__bridge void *)(self.localVideo));
            
            timerCallDuration = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(inCallTick:)
                                                               userInfo:nil
                                                                repeats:YES];
            
            startCallTime = [[NSDate date] timeIntervalSince1970];
            self.labelCallState.stringValue = @"Connected 00:00";
        }
            break;
        case LinphoneCallOutgoingInit: {
            self.labelCallState.stringValue = @"Calling 00:00";
        }
            break;
        case LinphoneCallOutgoingRinging: {
            self.labelCallState.stringValue = @"Ringing 00:00";
            
            [self startRingCountTimer];
        }
            break;
        case LinphoneCallPausedByRemote:
        case LinphoneCallStreamsRunning:
        {
            //            [self changeCurrentView:[InCallViewController compositeViewDescription]];
            break;
        }
        case LinphoneCallUpdatedByRemote:
        {
            const LinphoneCallParams* current = linphone_call_get_current_params(call);
            const LinphoneCallParams* remote = linphone_call_get_remote_params(call);
            
            /* remote wants to add video, check if video is supported */
            if (linphone_core_video_supported(lc) && !linphone_call_params_video_enabled(current) && linphone_call_params_video_enabled(remote)) {
                
                linphone_core_defer_call_update(lc, call);
                LinphoneCallParams* paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
                linphone_call_params_enable_video(paramsCopy, TRUE);
                linphone_core_accept_call_update(lc, call, paramsCopy);
                linphone_call_params_destroy(paramsCopy);
                
            } else if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
                //                [self displayTableCall:animated];
            }
            break;
        }
        case LinphoneCallError:
        {
            [self stopRingCountTimer];
            [self stopCallFlashingAnimation];
            [self displayCallError:call message:@"Call Error"];
            self.numpadView.hidden = YES;

            break;
        }
        case LinphoneCallEnd:
        {
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
    
    [callInfoWindowController close];
    callInfoWindowController = nil;
    
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
    [[[CallService sharedInstance] getCallWindowController].window setTitle:[NSString stringWithFormat:windowTitle, address, [self getTimeStringFromSeconds:0]]];
}

#pragma mark - CallControllersView Delegate

- (void) didClickCallControllersViewNumpad:(CallControllersView*)callControllersView_ {
    self.numpadView.hidden = !self.numpadView.hidden;
}


#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    call = acall;
    [self update];
    [self callUpdate:call state:linphone_call_get_state(call)];
    
    [self.callControllersView setCall:acall];
}

- (void)setOutgoingCall:(LinphoneCall*)acall {
    call = acall;
    [self update];
    
    [self.callControllersView setOutgoingCall:acall];
}

- (void) inCallTick:(NSTimer*)timer {
    NSTimeInterval callDuration = [[NSDate date] timeIntervalSince1970] - startCallTime;
    
    NSString *string_time = [self getTimeStringFromSeconds:callDuration];
    //Update call duration in window title
    
    self.labelCallState.stringValue = [NSString stringWithFormat:@"Connected %@",string_time];
    [[[CallService sharedInstance] getCallWindowController].window setTitle:[NSString stringWithFormat:windowTitle, address, string_time]];
}

-(NSString *)getTimeStringFromSeconds:(int)seconds
{
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    return [dcFormatter stringFromTimeInterval:seconds];
}

- (void)startRingCountTimer {
    self.ringCountLabel.hidden = NO;
    [self ringCountTimer];
    timerRingCount = [NSTimer scheduledTimerWithTimeInterval:1
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
    
    self.ringCountLabel.hidden = YES;
}

- (void)ringCountTimer {
    self.ringCountLabel.stringValue = [@(self.ringCountLabel.stringValue.intValue + 1) stringValue];
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

@end
