//
//  VideoMailWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "VideoMailWindowController.h"
#import "LinphoneManager.h"

@interface VideoMailWindowController ()

@end

@implementation VideoMailWindowController

@synthesize isShow;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
    
    linphone_core_enable_video_preview([LinphoneManager getLc], FALSE);
    linphone_core_use_preview_window([LinphoneManager getLc], FALSE);
    linphone_core_set_native_preview_window_id([LinphoneManager getLc], LINPHONE_VIDEO_DISPLAY_NONE);
}

- (void) enableSelfVideo {
    linphone_core_enable_video_preview([LinphoneManager getLc], TRUE);
    linphone_core_use_preview_window([LinphoneManager getLc], YES);
    linphone_core_set_native_preview_window_id([LinphoneManager getLc], (__bridge void *)(self.contentViewController.view));
    linphone_core_enable_self_view([LinphoneManager getLc], TRUE);
}

@end
