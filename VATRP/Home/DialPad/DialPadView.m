//
//  DialPadView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "DialPadView.h"
#import "Utils.h"
#import "LinphoneManager.h"
#import "CallService.h"
#import "ViewManager.h"


@interface DialPadView () {
    
}

@property (weak) IBOutlet NSTextField *textFieldNumber;
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
@property (weak) IBOutlet NSButton *buttonCall;
@property (weak) IBOutlet NSButton *buttonProvider;

@end


@implementation DialPadView


- (void) awakeFromNib {
    [super awakeFromNib];
 
    [self setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0]];

    // Title color
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonOne];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonTwo];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonThree];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonFour];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonFive];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonSix];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonSeven];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonEight];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonNine];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonZero];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonStar];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonSharp];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonCall];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonProvider];
    
    // Border color
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonOne];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonTwo];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonThree];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonFour];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonFive];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonSix];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonSeven];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonEight];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonNine];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonZero];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonStar];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonSharp];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonCall];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonProvider];
    
    [[self.buttonCall layer] setBackgroundColor:[NSColor colorWithRed:13.0/255.0 green:110.0/255.0 blue:15.0/255.0 alpha:1.0].CGColor];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)onButtonNumber:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    switch (button.tag) {
        case 10: {
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"*"];
            linphone_core_play_dtmf([LinphoneManager getLc], '*', 100);
        }
            break;
        case 11: {
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"#"];
            linphone_core_play_dtmf([LinphoneManager getLc], '#', 100);
        }
            break;
        default: {
            NSString *number = [NSString stringWithFormat:@"%ld", (long)button.tag];
            const char *charArray = [number UTF8String];
            char charNumber = charArray[0];
            linphone_core_play_dtmf([LinphoneManager getLc], charNumber, 100);
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:number];
        }
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DIALPAD_TEXT_CHANGED object:self.textFieldNumber.stringValue];
}

- (IBAction)onButtonVideo:(id)sender {
    [CallService callTo:self.textFieldNumber.stringValue];
}

- (IBAction)onButtonDelete:(id)sender {
    if (self.textFieldNumber.stringValue.length) {
        self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue substringToIndex:self.textFieldNumber.stringValue.length-1];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:DIALPAD_TEXT_CHANGED object:self.textFieldNumber.stringValue];
}

- (void) dealloc {
    NSLog(@"dealloc");
}

- (void)viewDidMoveToSuperview {
    NSLog(@"viewDidMoveToSuperview");
    
    [self addSubview:self.buttonOne];
    [self.buttonOne setFrame:NSMakeRect(0, 176, 103, 44)];
}

@end
