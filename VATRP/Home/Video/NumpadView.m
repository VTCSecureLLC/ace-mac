//
//  NumpadView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/18/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "NumpadView.h"
#import "LinphoneManager.h"

@interface NumpadView () {
    
}

@property (weak) IBOutlet BackgroundedView *viewBG;
@property (weak) IBOutlet NSButton *buttonOne;
@property (weak) IBOutlet NSButton *buttonTwo;
@property (weak) IBOutlet NSButton *buttonThree;
@property (weak) IBOutlet NSButton *buttonFour;
@property (weak) IBOutlet NSButton *buttonFive;
@property (weak) IBOutlet NSButton *buttonSix;
@property (weak) IBOutlet NSButton *buttonSeven;
@property (weak) IBOutlet NSButton *buttonEight;
@property (weak) IBOutlet NSButton *buttonNine;
@property (weak) IBOutlet NSButton *buttonZero;
@property (weak) IBOutlet NSButton *buttonStar;
@property (weak) IBOutlet NSButton *buttonSharp;

@end

@implementation NumpadView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.wantsLayer = YES;
    self.viewBG.wantsLayer = YES;
    
    [self.viewBG setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:1.0]];
    [self setBackgroundColor:[NSColor clearColor]];
    
    [self.buttonOne.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonTwo.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonThree.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonFour.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonFive.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonSix.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonSeven.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonEight.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonNine.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonZero.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonStar.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [self.buttonSharp.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
}

- (void)mouseDown:(NSEvent *)theEvent {
    self.hidden = YES;
}

- (IBAction)onButtonNumber:(id)sender {
    NSButton *button = (NSButton*)sender;
    [button.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:1.0].CGColor];
    [self performSelector:@selector(resetBackgroundColorOfButton:) withObject:button afterDelay:0.2];
    
    LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
    
    if (!call) {
        return;
    }
    
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

- (void) resetBackgroundColorOfButton:(NSButton*)button {
    [button.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
}

@end
