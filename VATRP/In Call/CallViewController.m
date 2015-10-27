//
//  CallViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallViewController.h"
#import "VideoCallViewController.h"
#import "CallInfoWindowController.h"
#import "SettingsWindowController.h"
#import "KeypadWindowController.h"
#import "ChatWindowController.h"
#import "CallService.h"
#import "ChatService.h"
#import "AppDelegate.h"


@interface CallViewController () {
    NSTimer *timerCallDuration;
    NSTimer *timerRingCount;
    NSTimeInterval startCallTime;
    
    CallInfoWindowController *callInfoWindowController;
    NSTimer *callAlertTimer;
    NSImage *alert;
    NSImage *alertInverted;
    KeypadWindowController *keypadWindowController;
    
    NSString *windowTitle, *address;
}

@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallState;
@property (weak) IBOutlet NSTextField *labelCallDuration;
@property (weak) IBOutlet NSButton *buttonAnswer;
@property (weak) IBOutlet NSButton *buttonDecline;
@property (weak) IBOutlet NSTextField *ringCountLabel;

@property (weak) IBOutlet NSImageView *callAlertImageView;


- (IBAction)onButtonAnswer:(id)sender;
- (IBAction)onButtonDecline:(id)sender;
- (IBAction)onButtonCallInfo:(id)sender;
- (IBAction)onButtonKeypad:(id)sender;
- (IBAction)onButtonOpenMessage:(id)sender;
- (void) inCallTick:(NSTimer*)timer;

@end

@implementation CallViewController

@synthesize call;

dispatch_queue_t callAlertAnimationQueue;
static const float callAlertStepInterval = 0.5;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    windowTitle  = @"Call with %@ duration: %@";
    address = @"";
    
    timerCallDuration = nil;
    callAlertTimer = nil;
    
    self.buttonAnswer.wantsLayer = YES;
    [self.buttonAnswer.layer setBackgroundColor:[NSColor greenColor].CGColor];
    self.buttonDecline.wantsLayer = YES;
    [self.buttonDecline.layer setBackgroundColor:[NSColor redColor].CGColor];
    
    self.view.wantsLayer = YES;
    self.remoteVideoView.wantsLayer = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
    alert = [NSImage imageNamed:@"alert"];
    alertInverted = [NSImage imageNamed:@"alert_inverted"];
    self.labelCallDuration.hidden = YES; //hiding this for now because of new remote view
    self.labelDisplayName.hidden = YES;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCallUpdate
                                                  object:nil];
}

- (IBAction)onButtonAnswer:(id)sender {
    [[CallService sharedInstance] accept];
}

- (IBAction)onButtonDecline:(id)sender {
    [[CallService sharedInstance] decline];
}

- (IBAction)onButtonOpenMessage:(id)sender {
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);
    NSString *userName = nil;
    
    if (addr != NULL) {
        const char* lUserName = linphone_address_get_username(addr);

        if (lUserName)
            userName = [NSString stringWithUTF8String:lUserName];
    }

    [[ChatService sharedInstance] openChatWindowWithUser:userName];
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
            self.labelCallState.stringValue = @"Incoming Call...";
            [self startRingCountTimer];
            [self startCallAlertTimer];

        }
        case LinphoneCallIncomingEarlyMedia:
        {
            break;
        }
        case LinphoneCallConnected: {
            [self labelCallState].hidden = YES;
            [self stopRingCountTimer];
            [self stopCallAlertTimer];

            CallWindowController *callWindow = [[CallService sharedInstance] getCallWindowController];
            [callWindow showWindow:self];
            CallViewController *callController = (CallViewController*)callWindow.contentViewController;
            linphone_core_set_native_video_window_id(lc, (__bridge void *)(callController.remoteVideoView));
            

            [[AppDelegate sharedInstance].viewController showVideoMailWindow];
            linphone_core_use_preview_window(lc, YES);
            linphone_core_set_native_preview_window_id(lc, (__bridge void *)([AppDelegate sharedInstance].viewController.videoMailWindowController.contentViewController.view));

            
            timerCallDuration = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(inCallTick:)
                                                               userInfo:nil
                                                                repeats:YES];
            startCallTime = [[NSDate date] timeIntervalSince1970];
            
            
            self.labelCallState.stringValue = @"Connected";
            self.buttonAnswer.hidden = YES;
            
            [self.buttonDecline setTitle:@"End Call"];
            self.buttonDecline.frame = CGRectMake((self.view.frame.size.width - self.buttonDecline.frame.size.width) / 2,
                                                  self.buttonDecline.frame.origin.y,
                                                  self.buttonDecline.frame.size.width,
                                                  self.buttonDecline.frame.size.height);
        }
            break;
        case LinphoneCallOutgoingInit: {
            self.labelCallState.stringValue = @"Calling...";
        }
            break;
        case LinphoneCallOutgoingRinging: {
            self.labelCallState.stringValue = @"Ringing...";

            [self startRingCountTimer];
            [self startCallAlertTimer];
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
            [self stopCallAlertTimer];
            self.labelCallState.stringValue = @"Call Error";
            //            [self displayCallError:call message: message];
        }
        case LinphoneCallEnd:
        {
            self.labelCallState.stringValue = @"Call End";
            [self stopRingCountTimer];
            [self stopCallAlertTimer];

            //            if (canHideInCallView) {
            //                // Go to dialer view
            //                DialerViewController *controller = DYNAMIC_CAST([self changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
            //                if(controller != nil) {
            //                    [controller setAddress:@""];
            //                    [controller setTransferMode:FALSE];
            //                }
            //            } else {
            //                [self changeCurrentView:[InCallViewController compositeViewDescription]];
            //            }
            break;
        }
        default:
            break;
    }
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
    [self view]; //Force view load
    
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
    //update caller address in window title
    [[[CallService sharedInstance] getCallWindowController].window setTitle:[NSString stringWithFormat:windowTitle, address, [self getTimeStringFromSeconds:0]]];
}


#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    call = acall;
    [self update];
    [self callUpdate:call state:linphone_call_get_state(call)];
}

- (void)setOutgoingCall:(LinphoneCall*)acall {
    call = acall;
    [self update];

    self.buttonAnswer.hidden = YES;
    self.buttonDecline.frame = CGRectMake((self.view.frame.size.width - self.buttonDecline.frame.size.width)/2,
                                          self.buttonDecline.frame.origin.y,
                                          self.buttonDecline.frame.size.width,
                                          self.buttonDecline.frame.size.height);
    [self.buttonDecline setTitle:@"Cancel"];
}

- (void) inCallTick:(NSTimer*)timer {
    NSTimeInterval callDuration = [[NSDate date] timeIntervalSince1970] - startCallTime;
    
    NSString *string_time = [self getTimeStringFromSeconds:callDuration];
    //Update call duration in window title
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

BOOL inverted = false;

-(void) callFlashAlert{
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(inverted){
                [_callAlertImageView setImage: alertInverted];
                inverted = false;
            }
            
            else{
                [_callAlertImageView setImage: alert];
                inverted = true;
            }
            
        });
        
    });
    
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

-(void)startCallAlertTimer{
    [_callAlertImageView setHidden:NO];
    callAlertAnimationQueue = dispatch_queue_create("alert queue",DISPATCH_QUEUE_PRIORITY_DEFAULT);
    callAlertTimer = [NSTimer scheduledTimerWithTimeInterval:callAlertStepInterval target:self selector:@selector(callFlashAlert) userInfo:nil repeats:true];
    [callAlertTimer fire];
}

-(void)stopCallAlertTimer{
    if (callAlertTimer && [callAlertTimer isValid]) {
        [callAlertTimer invalidate];
        callAlertTimer = nil;

    }
    [_callAlertImageView setHidden:YES];
}

- (void)ringCountTimer {
    self.ringCountLabel.stringValue = [@(self.ringCountLabel.stringValue.intValue + 1) stringValue];
}

@end
