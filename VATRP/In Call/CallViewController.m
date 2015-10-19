//
//  CallViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallViewController.h"
#import "VideoCallViewController.h"
#import "KeypadWindowController.h"
#import "ChatWindowController.h"
#import "CallService.h"
#import "ChatService.h"
#import "AppDelegate.h"


@interface CallViewController () {
    NSTimer *timerCallDuration;
    NSTimer *timerRingCount;
    NSTimeInterval startCallTime;
    
    KeypadWindowController *keypadWindowController;
}

@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallState;
@property (weak) IBOutlet NSTextField *labelCallDuration;
@property (weak) IBOutlet NSButton *buttonAnswer;
@property (weak) IBOutlet NSButton *buttonDecline;
@property (weak) IBOutlet NSTextField *ringCountLabel;

@property (weak) IBOutlet NSImageView *callAlertImageView;
@property (weak) NSImage *alert;
@property (weak) NSImage *alertInverted;

@property (weak) NSTimer *callAlertTimer;

- (IBAction)onButtonAnswer:(id)sender;
- (IBAction)onButtonDecline:(id)sender;
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
    
    timerCallDuration = nil;
    self.buttonAnswer.wantsLayer = YES;
    [self.buttonAnswer.layer setBackgroundColor:[NSColor greenColor].CGColor];
    self.buttonDecline.wantsLayer = YES;
    [self.buttonDecline.layer setBackgroundColor:[NSColor redColor].CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];

    _alert = [NSImage imageNamed:@"alert"];
    _alertInverted = [NSImage imageNamed:@"alert_inverted"];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCallUpdate
                                                  object:nil];
}

- (IBAction)onButtonAnswer:(id)sender {
    [[CallService sharedInstance] accept];
  
    if(_callAlertTimer != nil){
        [_callAlertTimer invalidate];
        _callAlertTimer = nil;
    }
}

- (IBAction)onButtonDecline:(id)sender {
    [[CallService sharedInstance] decline];
}

- (IBAction)onButtonOpenMessage:(id)sender {
    [[ChatService sharedInstance] openChatWindow];
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

    switch (astate) {
        case LinphoneCallIncomingReceived: {
            self.labelCallState.stringValue = @"Incoming Call...";
            
           // [self startRingCountTimer];
            
            callAlertAnimationQueue = dispatch_queue_create("alert queue",DISPATCH_QUEUE_PRIORITY_DEFAULT);
            _callAlertTimer = [NSTimer scheduledTimerWithTimeInterval:callAlertStepInterval target:self selector:@selector(callFlashAlert) userInfo:nil repeats:true];
            [_callAlertTimer fire];
        }
        case LinphoneCallIncomingEarlyMedia:
        {
            break;
        }
        case LinphoneCallConnected: {
            [self stopRingCountTimer];
            VideoCallWindowController *videoCallWindowController = [[AppDelegate sharedInstance] getVideoCallWindow];
            [videoCallWindowController showWindow:self];
            VideoCallViewController *videoCallViewController = (VideoCallViewController*)videoCallWindowController.contentViewController;
            linphone_core_set_native_video_window_id([LinphoneManager getLc], (__bridge void *)(videoCallViewController.view));
            

            [[AppDelegate sharedInstance].viewController showVideoMailWindow];
            linphone_core_use_preview_window([LinphoneManager getLc], YES);
            linphone_core_set_native_preview_window_id([LinphoneManager getLc], (__bridge void *)([AppDelegate sharedInstance].viewController.videoMailWindowController.contentViewController.view));


            self.labelCallState.stringValue = @"Connected";

            self.buttonAnswer.hidden = YES;
            self.buttonDecline.frame = CGRectMake((self.view.frame.size.width - self.buttonDecline.frame.size.width)/2,
                                                  self.buttonDecline.frame.origin.y,
                                                  self.buttonDecline.frame.size.width,
                                                  self.buttonDecline.frame.size.height);
            
            [self.buttonDecline setTitle:@"End Call"];
            
            self.labelCallDuration.hidden = NO;
            timerCallDuration = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(inCallTick:)
                                                               userInfo:nil
                                                                repeats:YES];
            startCallTime = [[NSDate date] timeIntervalSince1970];
        }
            break;
        case LinphoneCallOutgoingInit: {
            self.labelCallState.stringValue = @"Calling...";
        }
            break;
        case LinphoneCallOutgoingRinging: {
            self.labelCallState.stringValue = @"Ringing...";

            [self startRingCountTimer];
        }
            break;
        case LinphoneCallPausedByRemote:
        case LinphoneCallStreamsRunning:
        {
            //            [self changeCurrentView:[InCallViewController compositeViewDescription]];
            break;
        }
        case LinphoneCallError:
        {
            [self stopRingCountTimer];
            self.labelCallState.stringValue = @"Call Error";
            //            [self displayCallError:call message: message];
        }
        case LinphoneCallEnd:
        {
            self.labelCallState.stringValue = @"Call End";
            [self stopRingCountTimer];
            break;
        }
        default:
            break;
    }
}


- (void)dismiss {
    VideoCallWindowController *videoCallWindowController = [[AppDelegate sharedInstance] getVideoCallWindow];
    [videoCallWindowController close];

    if (timerCallDuration && [timerCallDuration isValid]) {
        [timerCallDuration invalidate];
        timerCallDuration = nil;
    }
}

- (void)update {
    [self view]; //Force view load
    
    NSString* address = nil;
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
    self.labelCallDuration.stringValue = string_time;
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
                [_callAlertImageView setImage: _alertInverted];
                inverted = false;
            }
            
            else{
                [_callAlertImageView setImage: _alert];
                inverted = true;
            }
            
        });
        
    });
    
}

- (void)startRingCountTimer {
    self.ringCountLabel.hidden = NO;
    [self ringCountTimer];
    timerRingCount = [NSTimer scheduledTimerWithTimeInterval:3.75
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

@end
