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
#import "ViewManager.h"
#import "AppDelegate.h"
#import "CallQualityIndicator.h"
#import "Utils.h"


@interface VideoView () <CallControllersViewDelegate> {
    NSTimer *timerCallDuration;
    NSTimer *timerRingCount;
    
    KeypadWindowController *keypadWindowController;
    
    NSString *windowTitle, *address;

    NumpadView *numpadView;
}

@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallState;
@property (weak) IBOutlet NSTextField *labelCallDuration;

@property (weak) IBOutlet BackgroundedView *callControllsConteinerView;
@property (weak) IBOutlet CallControllersView *callControllersView;
@property (weak) IBOutlet SecondIncomingCallView *secondIncomingCallView;
@property (weak) IBOutlet SecondCallView *secondCallView;

@property (weak) IBOutlet NSTextField *labelRingCount;

@property (weak) IBOutlet NSImageView *callAlertImageView;
@property (weak) IBOutlet NSView *localVideo;
@property (weak) IBOutlet NSButton *buttonFullScreen;

@property (weak) IBOutlet NSImageView *imageViewShadow;


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
    self.buttonFullScreen.wantsLayer = YES;
    [self.callControllsConteinerView setBackgroundColor:[NSColor clearColor]];
    
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonFullScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callViewFrameChange:)
                                                 name:@"CallViewFrameChange"
                                               object:nil];
    
//    self.labelDisplayName.hidden = YES;
    
    self.callControllersView.delegate = self;
}

- (void)createNumpadView {
    numpadView = [[NumpadView alloc] initWithFrame:NSMakeRect(0, 0, 720, 700)];
    numpadView.hidden = YES;
    [self.callControllsConteinerView addSubview:numpadView positioned:NSWindowAbove relativeTo:nil];
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
            [[AppDelegate sharedInstance].homeWindowController getHomeViewController].callQualityIndicator.hidden = YES;
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

            HomeViewController *homeViewController = [[AppDelegate sharedInstance].homeWindowController getHomeViewController];
            if (homeViewController.isAppFullScreen) {
                [[self.localVideo animator] setFrame:NSMakeRect([NSScreen mainScreen].frame.size.width - 234, [NSScreen mainScreen].frame.size.height - 120, 176, 99)];
            } else {
                [[self.localVideo animator] setFrame:NSMakeRect(507, 580, 176, 99)];
            }
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAllCallControllers) object:nil];
            [self performSelector:@selector(hideAllCallControllers) withObject:nil afterDelay:3.0];
            
            homeViewController.callQualityIndicator.hidden = NO;
            [homeViewController.callQualityIndicator setNeedsDisplayInRect:self.frame];
        }
            break;
        case LinphoneCallOutgoingInit: {
            [[AppDelegate sharedInstance].homeWindowController getHomeViewController].callQualityIndicator.hidden = YES;
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
            numpadView.hidden = YES;
            self.call = nil;
            [[AppDelegate sharedInstance].homeWindowController getHomeViewController].callQualityIndicator.hidden = YES;

            break;
        }
        case LinphoneCallEnd:
        {
            linphone_core_enable_video_preview(lc, FALSE);
            linphone_core_use_preview_window(lc, FALSE);
            linphone_core_enable_self_view([LinphoneManager getLc], FALSE);

            self.call = nil;
            numpadView.hidden = YES;
            [self stopRingCountTimer];
            [self stopCallFlashingAnimation];
            
            if([AppDelegate sharedInstance].viewController.videoMailWindowController.isShow){
                [[AppDelegate sharedInstance].viewController.videoMailWindowController close];
            }
            
            [[AppDelegate sharedInstance].homeWindowController getHomeViewController].callQualityIndicator.hidden = YES;

            break;
        }
        default:
            break;
    }
}

- (void)displayCallError:(LinphoneCall *)call_ message:(NSString *)message {
    NSString *lMessage;
    NSString *lTitle;
    const LinphoneAddress *address;
    NSString* lUserName = NSLocalizedString(@"Unknown", nil);
    if (call_ == nil)
    {
        lMessage = @"There was an unknown error during the call.";
    }
    else
    {
        address = linphone_call_get_remote_address(call_);
        if (address != nil)
        {
            const char *lUserNameChars = linphone_address_get_username(address);
            lUserName =
                lUserNameChars ? [[NSString alloc] initWithUTF8String:lUserNameChars] : NSLocalizedString(@"Unknown", nil);
        }
    }
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
    numpadView.hidden = !numpadView.hidden;
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
        
        float quality = linphone_call_get_current_quality(call);
        NSLog(@"quality quality quality quality quality quality quality quality quality: %f", quality);
        HomeViewController *homeViewController = [[AppDelegate sharedInstance].homeWindowController getHomeViewController];
        homeViewController.callQualityIndicator.callQuality = quality;
        [homeViewController.callQualityIndicator setNeedsDisplayInRect:homeViewController.callQualityIndicator.frame];
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

- (IBAction)onButtonFullScreen:(id)sender {
    [self hideAppMainBody:YES];
    
    NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
    [window setStyleMask:[window styleMask] | NSResizableWindowMask]; // resizable
    [window toggleFullScreen:self];
}

- (void)windowWillEnterFullScreen {
}

- (void)windowDidEnterFullScreen {
    
    if ([self.callControllersView bool_chat_window_open]) {
        [[[ViewManager sharedInstance].callView animator] setFrame:NSMakeRect(0, 0, [NSScreen mainScreen].frame.size.width - 298, [NSScreen mainScreen].frame.size.height)];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallViewFrameChange" object:NSStringFromRect(NSMakeRect(0, 0, [NSScreen mainScreen].frame.size.width - 298, [NSScreen mainScreen].frame.size.height))];
        HomeViewController *homeViewController = [[AppDelegate sharedInstance].homeWindowController getHomeViewController];
        homeViewController.rttView.hidden = NO;
    } else {
        [[[ViewManager sharedInstance].callView animator] setFrame:NSMakeRect(0, 0, [NSScreen mainScreen].frame.size.width, [NSScreen mainScreen].frame.size.height)];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallViewFrameChange" object:NSStringFromRect(NSMakeRect(0, 0, [NSScreen mainScreen].frame.size.width, [NSScreen mainScreen].frame.size.height))];
    }
    
    [self.buttonFullScreen.cell setImage:[NSImage imageNamed:@"icon_fullscreen_close"]];
}

- (void)windowWillExitFullScreen {
    [self hideAppMainBody:NO];
    
    [[numpadView animator] setFrame:NSMakeRect(0, 0, 720, 700)];
    [numpadView setCustomFrame:NSMakeRect(0, 0, 720, 700)];
}

- (void)windowDidExitFullScreen {
    [self hideAppMainBody:NO];

    if ([[CallService sharedInstance] getCurrentCall]) {
        if ([self.callControllersView bool_chat_window_open]) {
            if (self.window.frame.origin.x + 1328 > [[NSScreen mainScreen] frame].size.width) {
                [self.window setFrame:NSMakeRect([[NSScreen mainScreen] frame].size.width  - 1328 - 5, self.window.frame.origin.y, 1328, self.window.frame.size.height)
                              display:YES
                              animate:YES];
            } else {
                [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, 1328, self.window.frame.size.height)
                              display:YES
                              animate:YES];
            }
            
            [self.callControllersView set_bool_chat_window_open:YES];
        } else {
            [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, 1030, self.window.frame.size.height)
                          display:YES
                          animate:YES];
            [self.callControllersView set_bool_chat_window_open:NO];
        }
    }

    [self.callControllersView dismisCallInfoWindow];
    
    [self.buttonFullScreen.cell setImage:[NSImage imageNamed:@"icon_fullscreen_open"]];
    NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
    [window setStyleMask:[window styleMask] & ~NSResizableWindowMask]; // non-resizable
}

- (void) hideAppMainBody:(BOOL)hide {
    HomeViewController *homeViewController = [[AppDelegate sharedInstance].homeWindowController getHomeViewController];
    homeViewController.dockView.hidden = hide;
    homeViewController.profileView.hidden = hide;
    homeViewController.dialPadView.hidden = hide;
    homeViewController.viewContainer.hidden = hide;
    homeViewController.rttView.hidden = hide;
}

- (void)callViewFrameChange:(NSNotification*)notif {
    NSString *callViewFrameStr = (NSString*)notif.object;
    NSRect callViewFrame = NSRectFromString(callViewFrameStr);

    [[self animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];

    [[self.callControllsConteinerView animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    HomeViewController *homeViewController = [[AppDelegate sharedInstance].homeWindowController getHomeViewController];
    [[homeViewController.rttView animator] setFrame:NSMakeRect(callViewFrame.size.width, 0, homeViewController.rttView.frame.size.width, callViewFrame.size.height)];
    [homeViewController.rttView setCustomFrame:NSMakeRect(callViewFrame.size.width, 0, homeViewController.rttView.frame.size.width, callViewFrame.size.height)];
     
    [[self.localVideo animator] setFrame:NSMakeRect(callViewFrame.size.width - 240, callViewFrame.size.height - 120, self.localVideo.frame.size.width, self.localVideo.frame.size.height)];
    [[self.buttonFullScreen animator] setFrame:NSMakeRect(callViewFrame.size.width - 35, callViewFrame.size.height - 52, self.buttonFullScreen.frame.size.width, self.buttonFullScreen.frame.size.height)];
    [[self.labelDisplayName animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelDisplayName.frame.size.width/2, callViewFrame.size.height - 101, self.labelDisplayName.frame.size.width, self.labelDisplayName.frame.size.height)];
    [[self.labelCallState animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelCallState.frame.size.width/2, callViewFrame.size.height - 146, self.labelCallState.frame.size.width, self.labelCallState.frame.size.height)];
    [[self.labelCallDuration animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelCallDuration.frame.size.width/2, callViewFrame.size.height - 170, self.labelCallDuration.frame.size.width, self.labelCallDuration.frame.size.height)];
    [[self.labelRingCount animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelCallDuration.frame.size.width/2, callViewFrame.size.height/2 - self.labelCallDuration.frame.size.height/2, self.labelRingCount.frame.size.width, self.labelRingCount.frame.size.height)];
    [[self.callControllersView animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.callControllersView.frame.size.width/2, 12, self.callControllersView.frame.size.width, self.callControllersView.frame.size.height)];
    [[self.secondIncomingCallView animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    [self.secondIncomingCallView reorderControllersForFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    [[self.secondCallView animator] setFrame:NSMakeRect(6, callViewFrame.size.height - 190, self.secondCallView.frame.size.width, self.secondCallView.frame.size.height)];
    [[numpadView animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    [numpadView setCustomFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    
    
    [[[[AppDelegate sharedInstance].homeWindowController getHomeViewController].callQualityIndicator animator] setFrame:CGRectMake(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
}

@end
