//
//  KeypadViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/13/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "KeypadViewController.h"
#import "LinphoneManager.h"

@interface KeypadViewController ()

@end

@implementation KeypadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.    
}

- (IBAction)onButtonNumber:(id)sender {
    LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
    
    if (!call) {
        return;
    }

    NSButton *button = (NSButton*)sender;
    int return_value = 0;
    
    switch (button.tag) {
        case 10: {
            return_value = linphone_call_send_dtmf(call, '*');
            linphone_core_play_dtmf([LinphoneManager getLc], '*', 100);
        }
            break;
        case 11: {
            return_value = linphone_call_send_dtmf(call, '#');
            linphone_core_play_dtmf([LinphoneManager getLc], '#', 100);
        }
            break;
        default: {
            NSString *number = [NSString stringWithFormat:@"%ld", (long)button.tag];
            const char *charArray = [number UTF8String];
            char charNumber = charArray[0];
            return_value = linphone_call_send_dtmf(call, charNumber);
            linphone_core_play_dtmf([LinphoneManager getLc], charNumber, 100);
        }
            break;
    }
    
    if (return_value != 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Can not send DTMF"];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}

@end
