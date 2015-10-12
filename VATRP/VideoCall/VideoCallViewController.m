//
//  VideoCallViewController.m
//  vatrp
//
//  Created by Ruben Semerjyan on 9/21/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "VideoCallViewController.h"
#import "AppDelegate.h"
#import "CallWindowController.h"
#import "CallViewController.h"
#import "SelfVideoViewController.h"
@interface VideoCallViewController ()

@end

@implementation VideoCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.view.window];
    // Do view setup here.
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSWindow *win = [notification object];
    CallWindowController *callWindowController = [AppDelegate sharedInstance].callWindowController;
    CallViewController *callViewController;
    
    if(callWindowController){
        callViewController = [callWindowController getCallViewController];
        
        if(callViewController){
            if(callViewController.call){
                LinphoneCore *lc = [LinphoneManager getLc];
                LinphoneCall *currentCall = linphone_core_get_current_call(lc);
                
                if(currentCall){
                    linphone_core_terminate_call(lc, callViewController.call);
                }
            }
        }
    }
}
@end
