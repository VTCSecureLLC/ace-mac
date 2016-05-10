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
#import "CallDeclineMessagesView.h"
#import "NumpadView.h"
#import "SecondIncomingCallView.h"
#import "SecondCallView.h"
#import <QuartzCore/QuartzCore.h>
#import "CallService.h"
#import "SettingsService.h"
#import "ChatService.h"
#import "ViewManager.h"
#import "AppDelegate.h"
#import "ContactPictureManager.h"
#import "Utils.h"
#import "BackgroundedView.h"
#import "SettingsHandler.h"
#import "LinphoneAPI.h"

@interface VideoView () <CallControllersViewDelegate, NSAnimationDelegate> {
    NSTimer *timerCallDuration;
    NSTimer *timerRingCount;
    
    KeypadWindowController *keypadWindowController;
    
    NSString *windowTitle, *address;

    CallDeclineMessagesView *callDeclineMessagesView;
    NumpadView *numpadView;
    NSImageView *cameraStatusModeImageView;
    BackgroundedView *blackCurtain;
    
    bool uiInitialized;
    bool observersAdded;
    bool displayErrorLock;
    
    NSViewAnimation *fadeOut;
    NSViewAnimation *fadeIn;
    NSDictionary *callErrorStatuses;
}

@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallState;
@property (weak) IBOutlet NSTextField *labelCallDuration;
@property (weak) IBOutlet NSTextField *labelCallDeclineMessage;
@property (weak) IBOutlet NSView *viewCallDeclineMessage;


@property (weak) IBOutlet BackgroundedView *callControllsConteinerView;

@property (strong) IBOutlet NSView *callControllerContainer;
@property (strong) IBOutlet CallControllersView *callControllersView;

@property (strong) IBOutlet NSView *secondCallContainer;
@property (strong) IBOutlet SecondCallView *secondCallView;
@property (strong) IBOutlet NSView *secondIncomingCallContainer;
@property (strong) IBOutlet SecondIncomingCallView *secondIncomingCallView;

@property (weak) IBOutlet NSTextField *labelRingCount;

@property (weak) IBOutlet NSImageView *callAlertImageView;
@property (weak) IBOutlet NSView *localVideo;
@property (weak) IBOutlet NSButton *buttonFullScreen;
@property (strong) IBOutlet NSView *remoteVideo;

@property (weak) IBOutlet NSImageView *callerImageView;
@property (strong,nonatomic)SettingsHandler* settingsHandler;
@property (strong) IBOutlet NSButton *buttonHangUp;

@property (strong, nonatomic) NSString *callStatusMessage;
@property (strong, nonatomic)IBOutlet NSImageView *holdImageView;

@property (weak) IBOutlet NSImageView *imageViewQuality;

@property (weak) IBOutlet NSImageView *imageViewEncription;

- (void) inCallTick:(NSTimer*)timer;

@end

@implementation VideoView

@synthesize call;

-(id) init
{
    self = [super initWithNibName:@"VideoView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

//-(void)viewDidLoad
//{
//    [super viewDidLoad];
//    [self initializeData];
//}

- (void) awakeFromNib {
    [super awakeFromNib];
    if (!uiInitialized)
    {
        [self initializeData];
        uiInitialized = true;
    }
}

- (void) initializeData
{
    windowTitle  = @"Call with %@ duration: %@";
    address = @"";
    
    timerCallDuration = nil;
    
    if (uiInitialized)
    {
        return;
    }
    self.settingsHandler = [SettingsHandler settingsHandler];
    self.settingsHandler.settingsSelfViewDelegate = self;
    
    self.view.wantsLayer = YES;
    self.remoteVideo.wantsLayer = YES;
    self.labelDisplayName.wantsLayer = YES;
    self.labelCallState.wantsLayer = YES;
    self.buttonFullScreen.wantsLayer = YES;
    self.callControllsConteinerView.wantsLayer = YES;
    [self.callControllsConteinerView setBackgroundColor:[NSColor clearColor]];
    
    
    callDeclineMessagesView = [[CallDeclineMessagesView alloc] initWithNibName:@"CallDeclineMessagesView" bundle:nil];
    callDeclineMessagesView.delegate = self;
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonFullScreen];
    
    
    //    self.labelDisplayName.hidden = YES;
    
    self.callControllersView.delegate = self;
    cameraStatusModeImageView = [[NSImageView alloc] initWithFrame:self.remoteVideo.frame];
    blackCurtain = [[BackgroundedView alloc] initWithFrame:self.remoteVideo.frame];
    [blackCurtain setBackgroundColor:[NSColor blackColor]];
    // ToD0 - temp for VATRP-2489
    [self.buttonFullScreen setHidden:true];
    
    
    
    self.callControllersView = [[CallControllersView alloc] init];
    self.callControllersView.delegate = self;
    [self.callControllerContainer addSubview:[self.callControllersView view]];
    
    //    self.callControllersView.view.hidden = true;
    self.secondCallView = [[SecondCallView alloc] init];
    [self.secondCallContainer addSubview:[self.secondCallView view]];
    self.secondCallView.view.hidden = true;
    self.secondIncomingCallView = [[SecondIncomingCallView alloc] init];
    [self.secondIncomingCallContainer addSubview:[self.secondIncomingCallView view]];
    [self.secondIncomingCallView setHidden:true];
    self.secondIncomingCallContainer.hidden = true;
    
    if (!observersAdded)
    {
        [self addObservers];
         observersAdded = true;
    }
    
    NSString *FileDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ResasonErrors.plist"];
    callErrorStatuses = [NSDictionary dictionaryWithContentsOfFile:FileDB];
    
}

-(void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callViewFrameChange:)
                                                 name:@"CallViewFrameChange"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoModeUpdate:)
                                                 name:kLinphoneVideModeUpdate
                                               object:nil];
}

- (void)createNumpadView {
    numpadView = [[NumpadView alloc] initWithFrame:NSMakeRect(0, 0, 720, 700)];
    numpadView.hidden = YES;
    [self.callControllsConteinerView addSubview:numpadView positioned:NSWindowAbove relativeTo:nil];
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//
//    // Drawing code here.
//}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onButtonKeypad:(id)sender {
//    keypadWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"KeypadWindowController"];
    keypadWindowController = [[KeypadWindowController alloc] init];
    [keypadWindowController showWindow:self];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey: @"state"] intValue];
    self.callStatusMessage = [notif.userInfo objectForKey:@"message"];
    [self callUpdate:acall state:astate];
}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
    if(call == acall && (astate == LinphoneCallEnd || astate == LinphoneCallError)) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
    }
    
    LinphoneCore *lc = [LinphoneManager getLc];
    self.holdImageView.hidden = YES;

    switch (astate) {
            //    LinphoneCallIncomingReceived, /**<This is a new incoming call */
        case LinphoneCallIncomingReceived: {
            self.imageViewEncription.image = nil;
            self.viewCallDeclineMessage.hidden = YES;
            [self setLabelCallStateText:@"Incoming Call 00:00"];
            [self startRingCountTimerWithTimeInterval:3.75];
            [self.labelRingCount setTextColor:[NSColor whiteColor]];
            [self startCallFlashingAnimation];
            if ([self.secondIncomingCallContainer isHidden] == true)
            {
                [self.callControllsConteinerView setHidden:NO];
            }
            [[[AppDelegate sharedInstance].homeWindowController getHomeViewController] reloadRecents];
        }
            //    LinphoneCallIncomingEarlyMedia, /**<We are proposing early media to an incoming call */
        case LinphoneCallIncomingEarlyMedia:
        {
            break;
        }
            //    LinphoneCallConnected, /**<Connected, the call is answered */
        case LinphoneCallConnected: {
            [self.callControllersView setCall:acall];
            
            [self stopCallFlashingAnimation];
            
            [self stopRingCountTimer];
            
            linphone_core_set_native_video_window_id(lc, (__bridge void *)(self.remoteVideo));
            
            [[AppDelegate sharedInstance].viewController showVideoMailWindow];
            
            timerCallDuration = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(inCallTick:)
                                                               userInfo:nil
                                                                repeats:YES];
            
            [self setLabelCallStateText:@"Connected 00:00"];
            
//            [self.localVideo setFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            
            HomeViewController *homeViewController = [[AppDelegate sharedInstance].homeWindowController getHomeViewController];
            if (homeViewController.isAppFullScreen) {
                [[self.localVideo animator] setFrame:NSMakeRect([NSScreen mainScreen].frame.size.width - 234, [NSScreen mainScreen].frame.size.height - 120, 176, 99)];
            } else {
                [[self.localVideo animator] setFrame:NSMakeRect(486, 580, 176, 99)];
            }
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAllCallControllers) object:nil];
            [self performSelector:@selector(hideAllCallControllers) withObject:nil afterDelay:3.0];
            [self showVideoPreview];
        }
            break;
            //    LinphoneCallOutgoingInit, /**<An outgoing call is started */
        case LinphoneCallOutgoingInit: {
            self.imageViewEncription.image = nil;
            self.viewCallDeclineMessage.hidden = YES;
            [self setLabelCallStateText:@"Calling 00:00"];
            [self.callControllsConteinerView setHidden:NO];
            [[[AppDelegate sharedInstance].homeWindowController getHomeViewController] reloadRecents];
        }
            break;
            //    LinphoneCallOutgoingRinging, /**<An outgoing call is ringing at remote end */
        case LinphoneCallOutgoingRinging: {
            self.imageViewEncription.image = nil;
            [self setLabelCallStateText:@"Ringing 00:00"];
            [self startRingCountTimerWithTimeInterval:3.6];
            [self.labelRingCount setTextColor:[NSColor redColor]];
        }
            break;
            //    LinphoneCallPaused, /**< The call is paused, remote end has accepted the pause */
        case LinphoneCallPaused: {
            self.imageViewEncription.image = nil;
            int call_Duration = linphone_call_get_duration(acall);
            NSString *string_time = [Utils getTimeStringFromSeconds:call_Duration];
            [self setLabelCallStateText:[NSString stringWithFormat:@"On Hold %@",string_time]];
            self.holdImageView.hidden = NO;
        }
            break;
            //    LinphoneCallStreamsRunning, /**<The media streams are established and running*/
        case LinphoneCallStreamsRunning:
        {
            // handle change for call waiting
            if (call != acall)
            {
                // update myself and references
                [self setCall:acall];
            }
//            SettingsHandler *settingsHandlerInstance = [SettingsHandler settingsHandler];
//            [self showSelfViewFromSettings:[settingsHandlerInstance isShowSelfViewEnabled]];

            [self.callerImageView setHidden:true];
            [self.callControllersView initializeButtonsFromSettings];
            linphone_core_enable_self_view(lc, [[SettingsHandler settingsHandler] isShowSelfViewEnabled]);
                
//            if ([SettingsService getShowPreview]) {
//                self.localVideo.hidden = NO;
//                linphone_core_enable_video_preview([LinphoneManager getLc], TRUE);
//                linphone_core_use_preview_window(lc, YES);
//                linphone_core_set_native_preview_window_id(lc, (__bridge void *)(self.localVideo));
//                linphone_core_enable_self_view([LinphoneManager getLc], TRUE);
//            } else {
//                self.localVideo.hidden = YES;
//            }
            //            [self changeCurrentView:[InCallViewController compositeViewDescription]];
            if ([self.callControllersView bool_chat_window_open])
            {
                [self.callControllersView performChatButtonClick];
            }

            [self setEncriptionStatusForCall:acall];
            break;
        }
            //    LinphoneCallError, /**<The call encountered an error*/
        case LinphoneCallError:
        {
            [callDeclineMessagesView dismissController:self];
            
            [self stopRingCountTimer];
            [self stopCallFlashingAnimation];
            // Disable self preview and set off the Mac camera.
            linphone_core_enable_video_preview(lc, FALSE);
            linphone_core_use_preview_window(lc, FALSE);
            linphone_core_enable_self_view([LinphoneManager getLc], FALSE);
            [self displayCallError:acall message:@"Call Error"];
            numpadView.hidden = YES;
            self.call = nil;

            if ([self.callControllersView bool_chat_window_open])
            {
                [self.callControllersView performChatButtonClick];
            }

            break;
        }
            //    LinphoneCallEnd, /**<The call ended normally*/
        case LinphoneCallEnd:
        {
            self.imageViewEncription.image = nil;
            [callDeclineMessagesView dismissController:self];

            if ((call != nil) && linphone_call_get_dir(call) == LinphoneCallOutgoing) {
                [self displayCallError:call message:@"Call Error"];
            }
            
            if(linphone_core_get_calls_nb([LinphoneManager getLc]) >= 1){
                const MSList *calls = linphone_core_get_calls([LinphoneManager getLc]);
                [[CallService sharedInstance] resume:ms_list_nth_data(calls, 0)];
            }
            else{
                if(blackCurtain){
                    [blackCurtain removeFromSuperview];
                }
                linphone_core_enable_video_preview(lc, FALSE);
                linphone_core_use_preview_window(lc, FALSE);
                linphone_core_enable_self_view([LinphoneManager getLc], FALSE);
                
                self.call = nil;
                [self.callerImageView setHidden:false];
            }
            
            numpadView.hidden = YES;
            [self stopRingCountTimer];
            [self stopCallFlashingAnimation];
            
            if([AppDelegate sharedInstance].viewController.videoMailWindowController.isShow){
                [[AppDelegate sharedInstance].viewController.videoMailWindowController close];
            }
            
            if ([self.callControllersView bool_chat_window_open])
            {
                [self.callControllersView performChatButtonClick];
            }
            break;
        }
            //    LinphoneCallIdle,					/**<Initial call state */
//        case LinphoneCallIdle :
//            break;
            //    LinphoneCallOutgoingProgress, /**<An outgoing call is in progress */
//        case LinphoneCallOutgoingProgress :
//            break;
            //    LinphoneCallOutgoingEarlyMedia, /**<An outgoing call is proposed early media */
//        case LinphoneCallOutgoingEarlyMedia :
//            break;
            //    LinphoneCallPausing, /**<The call is pausing at the initiative of local end */
//        case LinphoneCallPausing :
//            break;
            //    LinphoneCallResuming, /**<The call is being resumed by local end*/
//        case LinphoneCallResuming :
//            break;
            //    LinphoneCallRefered, /**<The call is being transfered to another party, resulting in a new outgoing call to follow immediately*/
//        case LinphoneCallRefered :
//            break;
            //    LinphoneCallPausedByRemote, /**<The call is paused by remote end*/
//        case LinphoneCallPausedByRemote :
//            break;
            //    LinphoneCallUpdatedByRemote, /**<The call's parameters change is requested by remote end, used for example when video is added by remote */
//        case LinphoneCallUpdatedByRemote :
//            break;
            //    LinphoneCallUpdating, /**<A call update has been initiated by us */
//        case LinphoneCallUpdating :
//            break;
            //    LinphoneCallReleased, /**< The call object is no more retained by the core */
//        case LinphoneCallReleased :
//            break;
            //    LinphoneCallEarlyUpdatedByRemote, /*<The call is updated by remote while not yet answered (early dialog SIP UPDATE received).*/
//        case LinphoneCallEarlyUpdatedByRemote :
//            break;
            //    LinphoneCallEarlyUpdating /*<We are updating the call while not yet answered (early dialog SIP UPDATE sent)*/
//        case LinphoneCallEarlyUpdating :
//            break;
        default:
            break;
    }
}

- (void)setEncriptionStatusForCall:(LinphoneCall*)acall {
    const LinphoneCallParams* current = linphone_call_get_current_params(acall);
    LinphoneMediaEncryption enc = linphone_call_params_get_media_encryption(current);
    NSString *str = [self encryptionToString:enc];
    if ([str isEqualToString:@"Encryption type None"]) {
        self.imageViewEncription.image = [NSImage imageNamed:@"security_ko"];
    } else {
        self.imageViewEncription.image = [NSImage imageNamed:@"security_ok"];
    }
}

- (NSString *)encryptionToString:(LinphoneMediaEncryption)state {
    switch (state) {
        case LinphoneMediaEncryptionNone:
            return @"Encryption type None";
            break;
        case LinphoneMediaEncryptionDTLS:
            return @"Encryption type DTLS";
            break;
        case LinphoneMediaEncryptionSRTP:
            return @"Encryption type SRTP";
            break;
        case LinphoneMediaEncryptionZRTP:
            return @"Encryption type ZRTP";
            break;
    }
}

- (void)displayCallError:(LinphoneCall *)call_ message:(NSString *)message
{
    NSString *lMessage;
    NSString *lTitle;
    const LinphoneAddress *linphoneAddress;
    NSString* lUserName = NSLocalizedString(@"Unknown", nil);
    if (call_ == nil)
    {
        lMessage = @"There was an unknown error during the call.";
    }
    else
    {
        linphoneAddress = linphone_call_get_remote_address(call_);
        if (address != nil)
        {
            const char *lUserNameChars = linphone_address_get_username(linphoneAddress);
            lUserName =
                lUserNameChars ? [[NSString alloc] initWithUTF8String:lUserNameChars] : NSLocalizedString(@"Unknown", nil);
        }
    }
    // get default proxy
    LinphoneProxyConfig *proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    if (proxyCfg == nil) {
        lMessage = NSLocalizedString(@"Please make sure your device is connected to the internet and double check your "
                                     @"SIP account configuration in the settings.",
                                     nil);
    } else {
        LinphoneReason reason = linphone_call_get_reason(call_);
        NSDictionary *dict = [callErrorStatuses objectForKey:[Utils callStateStringByIndex:[NSNumber numberWithInt:reason]]];
        
//        if (![[dict objectForKey:@"code"] isEqualToString:@""]) {
//            lMessage = [[[[dict objectForKey:@"message"] stringByAppendingString:@"(sip: "] stringByAppendingString:[dict objectForKey:@"code"]] stringByAppendingString:@")"];
//        } else {
//            lMessage = [dict objectForKey:@"message"];
//        }
        
        lMessage = [dict objectForKey:@"message"];
    }
    
    if (lMessage) {
        [self setLabelCallStateText:lMessage];
    }
}

- (void)dismiss {
    [[AppDelegate sharedInstance] dismissCallWindows];
    [self.callControllersView dismisCallInfoWindow];

    [self stopInCallTimer];

}
-(void)stopInCallTimer
{
    if (timerCallDuration && [timerCallDuration isValid]) {
        [timerCallDuration invalidate];
        timerCallDuration = nil;
    }
    
    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].dialPadView setDialerText:@""];
}

- (void)update {
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);
    char * remoteAddress = linphone_call_get_remote_address_as_string(call);
    NSString  *sipURI = [NSString stringWithUTF8String:remoteAddress];
    if (addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        if(useLinphoneAddress) {//
//            const char* lDisplayName = linphone_address_get_display_name(addr);
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
    
    
    NSDictionary *attributes = @{ NSStrokeColorAttributeName : [NSColor blackColor],
                                  NSForegroundColorAttributeName : [NSColor whiteColor],
                                  NSStrokeWidthAttributeName : [NSNumber numberWithInt:-3.0]};
    self.labelDisplayName.attributedStringValue = [[NSAttributedString alloc] initWithString:address attributes:attributes];
    [self.labelDisplayName sizeToFit];
    [self.labelDisplayName setFrame:NSMakeRect((self.view.frame.size.width - self.labelDisplayName.frame.size.width)/2,
                                               self.labelDisplayName.frame.origin.y,
                                               self.labelDisplayName.frame.size.width,
                                               self.labelDisplayName.frame.size.height)];
    
    //update caller address in window title
    [[[CallService sharedInstance] getCallWindowController].window setTitle:[NSString stringWithFormat:windowTitle, address, [Utils getTimeStringFromSeconds:0]]];
}

#pragma mark - CallControllersView Delegate

- (void) didClickCallControllersViewNumpad:(CallControllersView*)callControllersView_ {
    numpadView.hidden = !numpadView.hidden;
}

- (void) didClickCallControllersViewDeclineMessage:(CallControllersView*)callControllersView_ Opened:(BOOL)open {
    if (open) {
        [self presentViewController:callDeclineMessagesView
            asPopoverRelativeToRect:NSMakeRect(0,//[callControllersView_ getDeclineMessagesButton].frame.size.width,
                                               0, 100, 100)
                             ofView:[callControllersView_ getDeclineMessagesButton]
#if defined __MAC_10_9 || defined __MAC_10_8
                      preferredEdge:NSRectEdgeMinY
#else
                      preferredEdge:NSRectEdgeMinX
#endif
                           behavior:NSPopoverBehaviorApplicationDefined];

        
//        [self presentViewControllerAsModalWindow:callDeclineMessagesView];
    } else {
        
    }
}

#pragma mark - CallDeclineMessagesView Delegate

- (void) didClickCallDeclineMessagesViewItem:(CallDeclineMessagesView*)callDeclineMessagesView_ Message:(NSString*)message {
    message = [@"@@info@@ " stringByAppendingString:message];

    LinphoneChatRoom *room = linphone_call_get_chat_room(call);
    LinphoneChatMessage *msg = linphone_chat_room_create_message(room, [message UTF8String]);
    linphone_chat_room_send_message2(room, msg, nil, nil);
    
    [[CallService sharedInstance] decline:call];
}

#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    @synchronized (self) {
        call = acall;
        
        if (call) {
            [self update];
            [self.callControllersView setCall:call];
        }
        if (call == nil)
        {
            // invalidate the timer if there is no current call
            [self stopInCallTimer];
        }
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
    [self.secondIncomingCallView setHidden:false];
    [self.secondIncomingCallContainer setHidden:false];
    [self.callControllsConteinerView setHidden:true];
}

- (void)hideSecondIncomingCallView {
    [self.secondIncomingCallView setHidden:true];
    [self.secondIncomingCallContainer setHidden:true];
    [self.callControllsConteinerView setHidden:false];
}

- (void)setCallToSecondCallView:(LinphoneCall*)aCall {
    [self.secondCallView setCall:aCall];
    [self.secondCallView unlockSwap];
}

- (void)hideSecondCallView {
    [self.secondCallView setCall:nil];
    [self.secondCallView setHidden:YES];
    // verify that the call being held here is the current call
    LinphoneCall* remainingCall = [[CallService sharedInstance] getCurrentCall];
    if (remainingCall != call)
    {
        // then we need to update the call here and in children that retain a pointer to the call
        [self setCall:remainingCall];
        [[CallService sharedInstance] resume:remainingCall];
    } // otherwise the current call is the remaining call
    
    if (call == nil)
    {
        NSLog(@"VideoView.hideSecondCallView: The second call view is being hidden and the current call is null.");
    }
}

- (void) inCallTick:(NSTimer*)timer {
    @synchronized (self) {
        if (call) {
            int call_Duration = linphone_call_get_duration(call);
            NSString *string_time = [Utils getTimeStringFromSeconds:call_Duration];
            self.holdImageView.hidden = YES;
            LinphoneCallState call_state = linphone_call_get_state(call);
            
            switch (call_state) {
                case LinphoneCallConnected:
                case LinphoneCallStreamsRunning:
                {
                    [self setLabelCallStateText:[NSString stringWithFormat:@"Connected %@", string_time]];
                }
                    break;
                case LinphoneCallPaused:
                case LinphoneCallPausedByRemote:
                {
                    [self setLabelCallStateText:[NSString stringWithFormat:@"On Hold %@", string_time]];
                    self.holdImageView.hidden = NO;
                }
                    break;
                    
                default:
                    break;
            }
            
            int quality = (int)linphone_call_get_current_quality(call);
            
            switch (quality) {
                case 0:
                case 1:
                case 2: {
                    self.imageViewQuality.image = [NSImage imageNamed:[NSString stringWithFormat:@"call_quality_indicator_%d", quality]];
                }
                    break;
                default:
                    self.imageViewQuality.image = [NSImage imageNamed:@"call_quality_indicator_3"];
                    break;
            }
        }
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
    [self.view addSubview:self.labelRingCount positioned:NSWindowAbove relativeTo:nil];
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
    // in theory we should not need this, however, since we are working on a system where we do not control the order in which events are fired, this is a safe way to make sure that the user has the controls needed to cancel an outgoign call.
    if ([self.callControllsConteinerView isHidden] && [self.secondIncomingCallContainer isHidden])
    {
        [self.callControllsConteinerView setHidden:false];
    }
    self.labelRingCount.stringValue = [@(self.labelRingCount.intValue + 1) stringValue];
}

- (void) startCallFlashingAnimation {
    NSView *content = self.view;
    CALayer *layer = [content layer];
    
    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anime.fromValue = (id)[layer backgroundColor];
    anime.toValue = (id)CFBridgingRelease(CGColorCreateGenericRGB(0.8, 0.1, 0.1, 1.0));
    anime.duration = 0.5f;
    anime.autoreverses = YES;
    anime.repeatCount = 100;
    
    [layer addAnimation:anime forKey:@"backgroundColor"];
}

- (void) stopCallFlashingAnimation {
    NSView *content = self.view;
    CALayer *layer = [content layer];
    [layer removeAllAnimations];
}

- (void) startCallDeclineMessageAnimation {
    
    NSView *content = self.viewCallDeclineMessage;
    CALayer *layer = [content layer];
    
    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anime.fromValue = (id)[layer backgroundColor];
    anime.toValue = (id)CFBridgingRelease(CGColorCreateGenericRGB(1.0, 0.1, 0.1, 1.0));
    anime.duration = 0.5f;
    anime.autoreverses = YES;
    anime.repeatCount = 10;
    
    [layer addAnimation:anime forKey:@"backgroundColor"];
}

- (void) stopDeclineMessageAnimation {
    NSView *content = self.labelCallDeclineMessage;
    CALayer *layer = [content layer];
    [layer removeAllAnimations];
}

- (void)setMouseInCallWindow {
    if(!call) return;
    
    
    if ([self.secondIncomingCallView isHidden] == false)
    {
        return;
    }
    
    LinphoneCallState call_state = linphone_call_get_state(call);
    
    if (call_state == LinphoneCallConnected ||
        call_state == LinphoneCallStreamsRunning ||
        call_state == LinphoneCallPausing ||
        call_state == LinphoneCallPaused ||
        call_state == LinphoneCallPausedByRemote ||
        call_state == LinphoneCallUpdating ||
        call_state == LinphoneCallUpdatedByRemote) {
        [self.callControllsConteinerView setHidden:NO];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAllCallControllers) object:nil];
        [self performSelector:@selector(hideAllCallControllers) withObject:nil afterDelay:3.0];
    }
}

- (void) hideAllCallControllers {
    if (self.viewCallDeclineMessage.hidden) {
        [self.callControllsConteinerView setHidden:YES];
    }
}

- (void)showVideoPreview {
    bool previewEnabled = [[SettingsHandler settingsHandler] isShowSelfViewEnabled];
    if (call == nil)
    {
        [[LinphoneAPI instance] linphoneShowSelfPreview:previewEnabled];
    }
    if (previewEnabled) {
        LinphoneCore *lc = [LinphoneManager getLc];
        const char *cam = linphone_core_get_video_device(lc);
        linphone_core_set_video_device(lc, cam);
        linphone_core_enable_video_preview([LinphoneManager getLc], TRUE);
        linphone_core_use_preview_window(lc, YES);
        self.localVideo.hidden = NO;
        linphone_core_set_native_preview_window_id(lc, (__bridge void *)(self.localVideo));
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
        [homeViewController.rttView setHidden:false];
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
            if (self.view.window.frame.origin.x + 1328 > [[NSScreen mainScreen] frame].size.width) {
                [self.view.window setFrame:NSMakeRect([[NSScreen mainScreen] frame].size.width  - 1328 - 5, self.view.window.frame.origin.y, 1328, self.view.window.frame.size.height)
                              display:YES
                              animate:YES];
            } else {
                [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x, self.view.window.frame.origin.y, 1328, self.view.window.frame.size.height)
                              display:YES
                              animate:YES];
            }

            [self.callControllersView set_bool_chat_window_open:YES];
        } else {
            [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x, self.view.window.frame.origin.y, 1030, self.view.window.frame.size.height)
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
    [homeViewController hideDockView:hide];
    homeViewController.profileView.hidden = hide;
    homeViewController.dialPadView.hidden = hide;
    homeViewController.viewContainer.hidden = hide;
    [homeViewController.rttView setHidden:hide];
}

- (void)callViewFrameChange:(NSNotification*)notif {
    NSString *callViewFrameStr = (NSString*)notif.object;
    NSRect callViewFrame = NSRectFromString(callViewFrameStr);

    [[self.view animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];

    [[self.callControllsConteinerView animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    HomeViewController *homeViewController = [[AppDelegate sharedInstance].homeWindowController getHomeViewController];
    [[homeViewController.rttView.view animator] setFrame:NSMakeRect(callViewFrame.size.width, 0, homeViewController.rttView.view.frame.size.width, callViewFrame.size.height)];
    [homeViewController.rttView setCustomFrame:NSMakeRect(callViewFrame.size.width, 0, homeViewController.rttView.view.frame.size.width, callViewFrame.size.height)];
     
    [[self.localVideo animator] setFrame:NSMakeRect(callViewFrame.size.width - 240, callViewFrame.size.height - 120, self.localVideo.frame.size.width, self.localVideo.frame.size.height)];
    [[self.buttonFullScreen animator] setFrame:NSMakeRect(callViewFrame.size.width - 35, callViewFrame.size.height - 52, self.buttonFullScreen.frame.size.width, self.buttonFullScreen.frame.size.height)];
    [[self.labelDisplayName animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelDisplayName.frame.size.width/2, callViewFrame.size.height - 101, self.labelDisplayName.frame.size.width, self.labelDisplayName.frame.size.height)];
    [[self.labelCallState animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelCallState.frame.size.width/2, callViewFrame.size.height - 146, self.labelCallState.frame.size.width, self.labelCallState.frame.size.height)];
    [[self.labelCallDuration animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelCallDuration.frame.size.width/2, callViewFrame.size.height - 170, self.labelCallDuration.frame.size.width, self.labelCallDuration.frame.size.height)];
    [[self.viewCallDeclineMessage animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.viewCallDeclineMessage.frame.size.width/2, callViewFrame.size.height/2 - self.viewCallDeclineMessage.frame.size.height/2 - 140, self.viewCallDeclineMessage.frame.size.width, self.viewCallDeclineMessage.frame.size.height)];
    [[self.labelRingCount animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.labelRingCount.frame.size.width/2, callViewFrame.size.height/2 - self.labelRingCount.frame.size.height/2, self.labelRingCount.frame.size.width, self.labelRingCount.frame.size.height)];
    [[self.callControllersView.view animator] setFrame:NSMakeRect(callViewFrame.size.width/2 - self.callControllersView.view.frame.size.width/2, 12, self.callControllersView.view.frame.size.width, self.callControllersView.view.frame.size.height)];
    [[self.secondIncomingCallView.view animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    [self.secondIncomingCallView reorderControllersForFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    [[self.secondCallView.view animator] setFrame:NSMakeRect(6, callViewFrame.size.height - 190, self.secondCallView.view.frame.size.width, self.secondCallView.view.frame.size.height)];
    [[numpadView animator] setFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
    [numpadView setCustomFrame:NSMakeRect(0, 0, callViewFrame.size.width, callViewFrame.size.height)];
}

- (void)videoModeUpdate:(NSNotification*)notif {
    NSString *videoMode = [notif.userInfo objectForKey: @"videoModeStatus"];
    if ([videoMode isEqualToString:@"camera_mute_off"]) {
        [cameraStatusModeImageView setImage:[NSImage imageNamed:@"camera_mute.png"]];
        [blackCurtain addSubview:cameraStatusModeImageView];
        [self.view addSubview:blackCurtain];
        [self.view addSubview:self.callControllsConteinerView positioned:NSWindowAbove relativeTo:nil];
        [self.view addSubview:self.imageViewEncription positioned:NSWindowAbove relativeTo:nil];
        if (!self.localVideo.hidden) {
            [self.view addSubview:self.localVideo positioned:NSWindowAbove relativeTo:nil];
        }
    }
    if ([videoMode isEqualToString:@"isCameraMuted"] || [videoMode isEqualToString:@"camera_mute_on"]) {
        [blackCurtain removeFromSuperview];
    }
}

#pragma mark Settings delegates

-(void)showSelfViewFromSettings:(bool)show
{
    linphone_core_enable_self_view([LinphoneManager getLc], show);
    self.localVideo.hidden = !show;
    
}
// to cancel an out going call
- (IBAction)onHangUp:(NSButton *)sender
{
}

- (void)setDeclineMessage:(NSString*)declineMsg {
    [self startCallDeclineMessageAnimation];
    
    [self.callControllsConteinerView setHidden:NO];
    self.viewCallDeclineMessage.hidden = YES;
    [self setLabelCallStateText:@"Call declined"];
    self.labelCallDeclineMessage.stringValue = declineMsg;
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"mouseDown");
    
    if (!self.viewCallDeclineMessage.hidden) {
        self.viewCallDeclineMessage.hidden = YES;
    }
    
    if (!call) {
        [[CallService sharedInstance] closeCallWindow];
    }
}

- (void) setLabelCallStateText:(NSString*)text {
    NSDictionary *attributes = @{ NSStrokeColorAttributeName : [NSColor blackColor],
                                  NSForegroundColorAttributeName : [NSColor whiteColor],
                                  NSStrokeWidthAttributeName : [NSNumber numberWithInt:-3.0]};
    self.labelCallState.attributedStringValue = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.labelCallState sizeToFit];
    [self.labelCallState setFrame:NSMakeRect((self.view.frame.size.width - self.labelCallState.frame.size.width)/2,
                                               self.labelCallState.frame.origin.y,
                                               self.labelCallState.frame.size.width,
                                               self.labelCallState.frame.size.height)];
}

@end
