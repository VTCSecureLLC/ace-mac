//
//  CallDeclineMessagesView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 4/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "CallDeclineMessagesView.h"
#import "BackgroundedView.h"
#import "Utils.h"

@interface CallDeclineMessagesView ()

@property (weak) IBOutlet NSButton *buttonCallMeLater;
@property (weak) IBOutlet NSButton *buttonWatsUp;
@property (weak) IBOutlet NSButton *buttonInAMeeting;

@end

@implementation CallDeclineMessagesView

@synthesize delegate = _delegate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (id) init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    BackgroundedView *v = (BackgroundedView*)self.view;
    [v setBackgroundColor:[NSColor colorWithRed:230.0/255.0 green:91.0/255.0 blue:40.0/255.0 alpha:1.0]];
    
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonWatsUp];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonCallMeLater];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonInAMeeting];
    
    self.buttonWatsUp.wantsLayer = YES;
    self.buttonCallMeLater.wantsLayer = YES;
    self.buttonInAMeeting.wantsLayer = YES;
    
    [self.buttonWatsUp.layer setBackgroundColor:[NSColor colorWithRed:234.0/255.0 green:127.0/255.0 blue:58.0/255.0 alpha:1.0].CGColor];
    [self.buttonCallMeLater.layer setBackgroundColor:[NSColor colorWithRed:234.0/255.0 green:127.0/255.0 blue:58.0/255.0 alpha:1.0].CGColor];
    [self.buttonInAMeeting.layer setBackgroundColor:[NSColor colorWithRed:234.0/255.0 green:127.0/255.0 blue:58.0/255.0 alpha:1.0].CGColor];
}

- (IBAction) onButtonMessage:(id)sender {
    NSButton *button = (NSButton*)sender;
    NSString *message = @"";
    
    if (button == self.buttonCallMeLater) {
        message = @"Can't talk now. Call me later.";
    } else if (button == self.buttonWatsUp) {
        message = @"Can't talk now. What's up?";
    } else if (button == self.buttonInAMeeting) {
        message = @"I'm in a meeting.";
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didClickCallDeclineMessagesViewItem:Message:)]) {
        [_delegate didClickCallDeclineMessagesViewItem:self Message:message];
    }    
}

@end
