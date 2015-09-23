//
//  CallViewController.m
//  ACE
//
//  Created by Edgar Sukiasyan on 9/23/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "CallViewController.h"
#import "AppDelegate.h"


@interface CallViewController () {
    NSTimer *timerCallDuration;
    NSTimeInterval startCallTime;
}

@property (weak) IBOutlet NSTextField *labelDisplayName;
@property (weak) IBOutlet NSTextField *labelCallState;
@property (weak) IBOutlet NSTextField *labelCallDuration;
@property (weak) IBOutlet NSButton *buttonAnswer;
@property (weak) IBOutlet NSButton *buttonDecline;


- (IBAction)onButtonAnswer:(id)sender;
- (IBAction)onButtonDecline:(id)sender;
- (void) inCallTick:(NSTimer*)timer;

@end

@implementation CallViewController

@synthesize call;

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
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCallUpdate
                                                  object:nil];
}

- (IBAction)onButtonAnswer:(id)sender {
    [[LinphoneManager instance] acceptCall:call];
}

- (IBAction)onButtonDecline:(id)sender {
    linphone_core_terminate_call([LinphoneManager getLc], call);
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
//        [delegate incomingCallAborted:call];
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
    }
    
    switch (astate) {
        case LinphoneCallIncomingReceived: {
            self.labelCallState.stringValue = @"Incoming Call...";
        }
        case LinphoneCallIncomingEarlyMedia:
        {
            break;
        }
        case LinphoneCallConnected: {
            self.labelCallState.stringValue = @"Connected";

            self.buttonAnswer.hidden = YES;
            self.buttonDecline.frame = CGRectMake((self.view.frame.size.width - self.buttonDecline.frame.size.width)/2,
                                                  self.buttonDecline.frame.origin.y,
                                                  self.buttonDecline.frame.size.width,
                                                  self.buttonDecline.frame.size.height);
            
            [self.buttonDecline setTitle:@"End Call"];
            
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
        case LinphoneCallPausedByRemote:
        case LinphoneCallStreamsRunning:
        {
            //            [self changeCurrentView:[InCallViewController compositeViewDescription]];
            break;
        }
        case LinphoneCallUpdatedByRemote:
        {
            //            const LinphoneCallParams* current = linphone_call_get_current_params(call);
            //            const LinphoneCallParams* remote = linphone_call_get_remote_params(call);
            //
            //            if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
            //                [self changeCurrentView:[InCallViewController compositeViewDescription]];
            //            }
            break;
        }
        case LinphoneCallError:
        {
            self.labelCallState.stringValue = @"Call Error";
            //            [self displayCallError:call message: message];
        }
        case LinphoneCallEnd:
        {
            self.labelCallState.stringValue = @"Call End";
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
    [[AppDelegate sharedInstance].callWindowController close];
    
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
        char* lAddress = linphone_address_as_string_uri_only(addr);
        if(lAddress) {
//            NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:[NSString stringWithUTF8String:lAddress]];
//            ABRecordRef contact = [[[LinphoneManager instance] fastAddressBook] getContact:normalizedSipAddress];
//            if(contact) {
//                UIImage *tmpImage = [FastAddressBook getContactImage:contact thumbnail:false];
//                if(tmpImage != nil) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
//                        UIImage *tmpImage2 = [UIImage decodedImageWithImage:tmpImage];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            avatarImage.image = tmpImage2;
//                        });
//                    });
//                }
//                address = [FastAddressBook getContactDisplayName:contact];
//                useLinphoneAddress = false;
//            }
//            ms_free(lAddress);
        }
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            const char* lUserName = linphone_address_get_username(addr);
//            TODO: Address Book
//            if (lDisplayName)
//                address = [NSString stringWithUTF8String:lDisplayName];
//            else
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

@end
