//
//  VideoMailWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "VideoCallWindowController.h"
#import "VideoCallViewController.h"
#import "VideoMailWindowController.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"
#import "CallService.h"
#import "SelfVideoViewController.h"

@interface VideoMailWindowController ()

@end

@implementation VideoMailWindowController

@synthesize isShow;

-(id) init
{
    self = [super initWithWindowNibName:@"VideoMailWindowController"];
    if (self)
    {
        // init
        //        self.contentViewController = navigationController;
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    NSPoint barOrigin = [[AppDelegate sharedInstance] getTabWindowOrigin];
    
    NSPoint currentWindowSize = {self.window.frame.size.width, self.window.frame.size.height};
    NSPoint barWindowSize = [[AppDelegate sharedInstance] getTabWindowSize];
    
    NSPoint pos;
    pos.x = barOrigin.x + barWindowSize.x;
    pos.y = barOrigin.y;
    [self.window setFrameOrigin : pos];
    
    SelfVideoViewController* selfVideoViewController = [[SelfVideoViewController alloc] init];
    [self.window.contentView addSubview:[selfVideoViewController view]];
    
    [self.window setTitle:@"VideoMailWindowController"];

}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
    
    linphone_core_enable_video_preview([LinphoneManager getLc], FALSE);
    linphone_core_use_preview_window([LinphoneManager getLc], FALSE);
    linphone_core_set_native_preview_window_id([LinphoneManager getLc], LINPHONE_VIDEO_DISPLAY_NONE);
}

- (void) enableSelfVideo {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if(linphone_core_get_current_call(lc) != NULL){
        CallWindowController *videoCallWindowController = [[CallService sharedInstance] getCallWindowController];
        [videoCallWindowController showWindow:self];
        CallViewController *videoCallViewController = (CallViewController*)videoCallWindowController.contentViewController;
        linphone_core_set_native_video_window_id([LinphoneManager getLc], (__bridge void *)(videoCallViewController.remoteVideoView));
    }
    
    linphone_core_enable_video_preview([LinphoneManager getLc], TRUE);
    linphone_core_use_preview_window([LinphoneManager getLc], YES);
    linphone_core_set_native_preview_window_id([LinphoneManager getLc], (__bridge void *)(self.contentViewController.view));
    linphone_core_enable_self_view([LinphoneManager getLc], TRUE);
}

@end
