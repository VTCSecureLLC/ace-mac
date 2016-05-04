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
#import "AppDelegate.h"
#import "ProviderTableCellView.h"


@interface DialPadView () {
    BOOL plusWorked;
    NSArray *providersArray;
}

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
@property (weak) IBOutlet NSView *viewZeroButton;
@property (weak) IBOutlet NSTextField *textFieldStar;


@property (weak) IBOutlet NSTableView *providerTableView;
@property (weak) IBOutlet NSView *providersView;

@end


@implementation DialPadView

-(id) init
{
    self = [super initWithNibName:@"DialPadView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

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

    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(103, 44, 104, 44)
                                                                options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow )
                                                                  owner:self
                                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
    self.textFieldNumber.delegate = self;
    plusWorked = NO;
    [self initProvidersArray];
    [self setProviderInitialLogo];
    [self.providerTableView reloadData];
}

//-(void) initilializeData
//{
//}

-(void)hideProvidersView:(bool)hide
{
    [self.providersView setHidden:hide];
}

- (void)hideDialPad:(bool)hidden
{
    [self.buttonOne setHidden:hidden];
    [self.buttonTwo setHidden:hidden];
    [self.buttonThree setHidden:hidden];
    [self.buttonFour setHidden:hidden];
    [self.buttonFive setHidden:hidden];
    [self.buttonSix setHidden:hidden];
    [self.buttonSeven setHidden:hidden];
    [self.buttonEight setHidden:hidden];
    [self.buttonNine setHidden:hidden];
    [self.buttonZero setHidden:hidden];
    [self.buttonSharp setHidden:hidden];
    [self.buttonStar setHidden:hidden];
    
    [self.buttonCall setHidden:hidden];
    [self.buttonProvider setHidden:hidden];
    
    [self.view setHidden:hidden];
}

-(bool)isHidden
{
    return [self.view isHidden];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

#pragma mark - NSTextView delegate methods

- (void)controlTextDidChange:(NSNotification *)obj {
   [[NSNotificationCenter defaultCenter] postNotificationName:DIALPAD_TEXT_CHANGED object:self.textFieldNumber.stringValue];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    BOOL retval = NO;
    
    if (commandSelector == @selector(insertNewline:)) {
        
        retval = YES;
        // then finish editing and make the call
        [self.view.window makeFirstResponder:self.buttonCall];
        [self CallTo];
    }
    return retval;
}


- (IBAction)onButtonNumber:(id)sender {
    NSControl *control = (NSControl*)sender;
    
    switch (control.tag) {
        case 10:
        case 12: {
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
            NSString *number = [NSString stringWithFormat:@"%ld", (long)control.tag];
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
//    NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
//
//    [window setFrame:NSMakeRect([[NSScreen mainScreen] frame].size.width  - 1013 - 5, window.frame.origin.y, 1013, window.frame.size.height)
//             display:YES
//             animate:YES];
//    
//    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView showVideoPreview];
//    [self performSelector:@selector(CallTo) withObject:nil afterDelay:0.1];
    [self CallTo];
}

- (void) CallTo {
    // rudimentary test to ensure that we are not trying to call and empty address
    NSString* address = self.textFieldNumber.stringValue;
    if ((address != nil) && (address.length > 0))
    {
        [CallService callTo:self.textFieldNumber.stringValue];
    }
}

- (IBAction)onButtonDelete:(id)sender {
    if (self.textFieldNumber.stringValue.length) {
        self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue substringToIndex:self.textFieldNumber.stringValue.length-1];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:DIALPAD_TEXT_CHANGED object:self.textFieldNumber.stringValue];
}

- (void) mouseDown:(NSEvent *)theEvent {

    NSPoint curPoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];

    if (CGRectContainsPoint(self.buttonOne.frame, curPoint)) {
        [self onButtonNumber:self.buttonOne];
    } else if (CGRectContainsPoint(self.buttonTwo.frame, curPoint)) {
        [self onButtonNumber:self.buttonTwo];
    } else if (CGRectContainsPoint(self.buttonThree.frame, curPoint)) {
        [self onButtonNumber:self.buttonThree];
    } else if (CGRectContainsPoint(self.buttonFour.frame, curPoint)) {
        [self onButtonNumber:self.buttonFour];
    } else if (CGRectContainsPoint(self.buttonFive.frame, curPoint)) {
        [self onButtonNumber:self.buttonFive];
    } else if (CGRectContainsPoint(self.buttonSix.frame, curPoint)) {
        [self onButtonNumber:self.buttonSix];
    } else if (CGRectContainsPoint(self.buttonSeven.frame, curPoint)) {
        [self onButtonNumber:self.buttonSeven];
    } else if (CGRectContainsPoint(self.buttonEight.frame, curPoint)) {
        [self onButtonNumber:self.buttonEight];
    } else if (CGRectContainsPoint(self.buttonNine.frame, curPoint)) {
        [self onButtonNumber:self.buttonNine];
    } else if (CGRectContainsPoint(self.textFieldStar.frame, curPoint)) {
        [self onButtonNumber:self.textFieldStar];
    }
    [self performSelector:@selector(longPressPlus) withObject:nil afterDelay:1.0];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longPressPlus) object:nil];

    if (plusWorked) {
        plusWorked = NO;
        return;
    }
    
    CGPoint location = theEvent.locationInWindow;
    location.y = location.y - 80;
    
    if (CGRectContainsPoint(self.viewZeroButton.frame, location)) {
        linphone_core_play_dtmf([LinphoneManager getLc], '0', 100);
        self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"0"];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longPressPlus) object:nil];
}

- (void) longPressPlus {
    self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"+"];

    plusWorked = YES;
}

- (void) dealloc {
    NSString* linphoneVersion = [NSString stringWithUTF8String:linphone_core_get_version()];
    NSLog(@"dealloc - Dialpad. LinphoneVersion: %@", linphoneVersion);
}

- (void)viewDidMoveToSuperview {
    NSString* linphoneVersion = [NSString stringWithUTF8String:linphone_core_get_version()];
    NSLog(@"DialPadView.viewDidMoveToSuperview: LinphoneVersion: %@", linphoneVersion);
    
    [self.view addSubview:self.buttonOne];
    [self.buttonOne setFrame:NSMakeRect(0, 176, 103, 44)];
}

-(void)setDialerText:(NSString *)address{
    self.textFieldNumber.stringValue = address;
}
-(NSString*) getDialerText{
    return self.textFieldNumber.stringValue;
}
- (IBAction)onShowProviders:(NSButton *)sender
{
    bool currentlyHidden = self.providersView.hidden;
    [self.providersView setHidden:!currentlyHidden];
}

- (void)setProvButtonImage:(NSImage*)img {
    // VATRP-1514: Gray out option until general release.
//    NSImage *newImage = [img copy];
//    NSColor* tint = [NSColor grayColor];
//    if (tint) {
//        [newImage lockFocus];
//        [tint set];
//        NSRect imageRect = {NSZeroPoint, [newImage size]};
//        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
//        [newImage unlockFocus];
//    }
    [self.buttonProvider setImage:img];
}

- (void)initProvidersArray {
    providersArray = [[Utils cdnResources] mutableCopy];
    self.providerTableView.delegate = self;
    self.providerTableView.dataSource = self;
}

- (void)setProviderInitialLogo {
    NSDictionary *dict = [providersArray objectAtIndex:0];
    NSString *imageName = [dict objectForKey:@"providerLogo"];
    NSImage * providerLogo =  [[NSImage alloc] initWithContentsOfFile:imageName];
    [self setProvButtonImage:providerLogo];
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return providersArray.count;
}

#if defined __MAC_10_9 || defined __MAC_10_8
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
#else
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
#endif
    ProviderTableCellView *cellView = [tableView makeViewWithIdentifier:@"providerCell" owner:self];
    NSDictionary *dict = [providersArray objectAtIndex:row];
    NSString *imageName = [dict objectForKey:@"providerLogo"];
    [cellView.providerImageView setImage:[[NSImage alloc]initWithContentsOfFile:imageName]];
    
    return cellView;
}
    
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 53;
}
    
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{

    if([self.providersView isHidden]) return false;
    
    if (row >= 0 && row < providersArray.count)
    {
        NSDictionary *dict = [providersArray objectAtIndex:row];
        NSString *imageName = [dict objectForKey:@"providerLogo"];
        NSImage * providerLogo =  [[NSImage alloc] initWithContentsOfFile:imageName];
            
        [self setProvButtonImage:providerLogo];
        NSString *currentText = [self getDialerText];
        currentText = [currentText stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
        currentText = [currentText componentsSeparatedByString:@"@"][0];
        [self setDialerText:[NSString stringWithFormat:@"sip:%@@%@", currentText, [dict objectForKey:@"domain"]]];
        
        [self.providersView setHidden:true];
        return true;
    }
    return false;
}


@end
