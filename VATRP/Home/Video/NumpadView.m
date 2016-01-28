//
//  NumpadView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/18/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "NumpadView.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"

@interface NumpadView () {
    BackgroundedView *viewBG;

    NSButton *buttonOne;
    NSButton *buttonTwo;
    NSButton *buttonThree;
    NSButton *buttonFour;
    NSButton *buttonFive;
    NSButton *buttonSix;
    NSButton *buttonSeven;
    NSButton *buttonEight;
    NSButton *buttonNine;
    NSButton *buttonZero;
    NSButton *buttonStar;
    NSButton *buttonSharp;
}


@end

@implementation NumpadView

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        self.wantsLayer = YES;
        
        viewBG = [[BackgroundedView alloc] initWithFrame:NSMakeRect(frameRect.size.width/2 - 230/2, 217, 230, 307)];
        viewBG.wantsLayer = YES;
        [viewBG setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:1.0]];
        [self addSubview:viewBG];
        
        [self setBackgroundColor:[NSColor clearColor]];
        
        buttonOne = [self numpadButtonWithFrame:NSMakeRect(0, 231, 76, 76) Title:@"1" Tag:1];
        [viewBG addSubview:buttonOne];
        buttonTwo = [self numpadButtonWithFrame:NSMakeRect(77, 231, 76, 76) Title:@"2" Tag:2];
        [viewBG addSubview:buttonTwo];
        buttonThree = [self numpadButtonWithFrame:NSMakeRect(154, 231, 76, 76) Title:@"3" Tag:3];
        [viewBG addSubview:buttonThree];
        buttonFour = [self numpadButtonWithFrame:NSMakeRect(0, 154, 76, 76) Title:@"4" Tag:4];
        [viewBG addSubview:buttonFour];
        buttonFive = [self numpadButtonWithFrame:NSMakeRect(77, 154, 76, 76) Title:@"5" Tag:5];
        [viewBG addSubview:buttonFive];
        buttonSix = [self numpadButtonWithFrame:NSMakeRect(154, 154, 76, 76) Title:@"6" Tag:6];
        [viewBG addSubview:buttonSix];
        buttonSeven = [self numpadButtonWithFrame:NSMakeRect(0, 77, 76, 76) Title:@"7" Tag:7];
        [viewBG addSubview:buttonSeven];
        buttonEight = [self numpadButtonWithFrame:NSMakeRect(77, 77, 76, 76) Title:@"8" Tag:8];
        [viewBG addSubview:buttonEight];
        buttonNine = [self numpadButtonWithFrame:NSMakeRect(154, 77, 76, 76) Title:@"9" Tag:9];
        [viewBG addSubview:buttonNine];
        buttonZero = [self numpadButtonWithFrame:NSMakeRect(77, 0, 76, 76) Title:@"0" Tag:0];
        [viewBG addSubview:buttonZero];
        buttonStar = [self numpadButtonWithFrame:NSMakeRect(0, 0, 76, 76) Title:@"*" Tag:0];
        [viewBG addSubview:buttonStar];
        buttonSharp = [self numpadButtonWithFrame:NSMakeRect(154, 0, 76, 76) Title:@"#" Tag:0];
        [viewBG addSubview:buttonSharp];
    

        CGColorRef CGColor = [NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor;
        [buttonOne.layer setBackgroundColor:CGColor];
        [buttonTwo.layer setBackgroundColor:CGColor];
        [buttonThree.layer setBackgroundColor:CGColor];
        [buttonFour.layer setBackgroundColor:CGColor];
        [buttonFive.layer setBackgroundColor:CGColor];
        [buttonSix.layer setBackgroundColor:CGColor];
        [buttonSeven.layer setBackgroundColor:CGColor];
        [buttonEight.layer setBackgroundColor:CGColor];
        [buttonNine.layer setBackgroundColor:CGColor];
        [buttonZero.layer setBackgroundColor:CGColor];
        [buttonStar.layer setBackgroundColor:CGColor];
        [buttonSharp.layer setBackgroundColor:CGColor];
    }
    
    return self;
}

- (NSButton*) numpadButtonWithFrame:(NSRect)buttonFrame Title:(NSString*)title Tag:(NSInteger)tag {
    NSButton *button = [[NSButton alloc] initWithFrame:buttonFrame];
    [button setTitle:title];
    [button setTag:tag];
    [button setAction:@selector(onButtonNumber:)];
    [button setTarget:self];
    [button setFont:[NSFont systemFontOfSize:30.0]];
    [button setBezelStyle:NSRecessedBezelStyle];
    button.wantsLayer = YES;
    
    return button;
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

- (void) setCustomFrame:(NSRect)frame {
    [[viewBG animator] setFrame:NSMakeRect(frame.size.width/2 - viewBG.frame.size.width/2, 217, viewBG.frame.size.width, viewBG.frame.size.height)];
}

@end
