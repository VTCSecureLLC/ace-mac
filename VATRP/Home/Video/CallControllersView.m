//
//  CallControllersView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallControllersView.h"
#import "CallService.h"
#import "ChatService.h"

@implementation CallControllersView

- (IBAction)onButtonAnswer:(id)sender {
    [[CallService sharedInstance] accept];
}

- (IBAction)onButtonDecline:(id)sender {
    [[CallService sharedInstance] decline];
}

- (IBAction)onButtonOpenMessage:(id)sender {
    const LinphoneAddress* addr = linphone_call_get_remote_address([[CallService sharedInstance] getCurrentCall]);
    NSString *userName = nil;
    
    if (addr != NULL) {
        const char* lUserName = linphone_address_get_username(addr);
        
        if (lUserName)
            userName = [NSString stringWithUTF8String:lUserName];
    }
    
    [[ChatService sharedInstance] openChatWindowWithUser:userName];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
