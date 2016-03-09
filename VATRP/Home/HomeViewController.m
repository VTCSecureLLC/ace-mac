//
//  HomeViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewManager.h"
#import "CallService.h"
#import "RecentsView.h"
#import "VideoView.h"
#import "ContactsView.h"
#import "NumpadView.h"
#import "SettingsView.h"
#import "ProviderTableCellView.h"
#import "DHResourcesView.h"
#import "ResourcesViewController.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface HomeViewController () <DockViewDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    BackgroundedView *viewCurrent;
    NSArray *providersArray;
    NSColor *windowDefaultColor;
}

@property (weak) IBOutlet NSImageView *imageViewVoiceMail;
@property (weak) IBOutlet NSTextField *textFieldVoiceMailCount;

@property (strong) IBOutlet RecentsView *recentsView;
@property (strong) IBOutlet ContactsView *contactsView;
@property (weak) IBOutlet SettingsView *settingsView;
@property (weak) IBOutlet DHResourcesView *dhResourcesView;

@property (weak) IBOutlet NSTableView *providerTableView;
@property (weak) IBOutlet NSView *providersView;

@property bool hasProviderAlertBeenShown;
@end

@implementation HomeViewController
bool dialPadIsShown;
@synthesize isAppFullScreen;

-(id) init
{
    self = [super initWithNibName:@"HomeViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dialPadIsShown = true;
    // Do view setup here.
    [self activateMenuItems];
    
    windowDefaultColor = [NSColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    BackgroundedView *v = (BackgroundedView*)self.view;
    [v setBackgroundColor:windowDefaultColor];
    
    
    self.dockView = [[DockView alloc] init];
    [self.dockViewContainer addSubview:[self.dockView view]];
    self.dockView.delegate = self;

    self.profileView = [[ProfileView alloc] init];
    [self.profileViewContainer addSubview:[self.profileView view]];
    self.dialPadView = [[DialPadView alloc] init];
    [self.dialPadContainer addSubview:[self.dialPadView view]];

    self.rttView = [[RTTView alloc] init];
    [self.rttViewContainer addSubview:[self.rttView view]];
    
    [self.viewContainer setBackgroundColor:[NSColor whiteColor]];
    
//    self.recentsView = [[RecentsView alloc] init];
//    self.contactsView = [[ContactsView alloc] init];
//    [self.viewContainer addSubview:[self.recentsView view]];
//    [self.viewContainer addSubview:[self.contactsView view]];
    
    [ViewManager sharedInstance].dockView = self.dockView;
    [ViewManager sharedInstance].dialPadView = self.dialPadView;
    [ViewManager sharedInstance].profileView = self.profileView;
    [ViewManager sharedInstance].recentsView = self.recentsView;
    [ViewManager sharedInstance].callView = self.callView;
    
    viewCurrent = (BackgroundedView*)self.recentsView.view;
    [self initProvidersArray];
    [self setProviderInitialLogo];
    [self.providerTableView reloadData];
    [self.contactsView setBackgroundColor:[NSColor whiteColor]];
    
    [self.settingsView setBackgroundColor:[NSColor whiteColor]];

    [self setObservers];
    NSImageView *imgView;
    
    NSImage *img;
    [imgView setImage:img];
    
    self.hasProviderAlertBeenShown = false;
    
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"sip_mwi_uri"]){
        @try{
            NSString *videoMailUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"sip_mwi_uri"];
            if(videoMailUri && ![videoMailUri isEqualToString:@""]){
                LinphoneAddress *sipAddress = linphone_proxy_config_normalize_sip_uri(linphone_core_get_default_proxy_config([LinphoneManager getLc]), [videoMailUri UTF8String]);
                linphone_core_subscribe([LinphoneManager getLc], sipAddress, "message-summary", 1800, NULL);
            }
        }
        @catch(NSError *e){
            NSLog(@"Invalid MWI uri");
        }
    }
    self.isAppFullScreen = false;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillEnterFullScreen:) name:NSWindowWillEnterFullScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidEnterFullScreen:) name:NSWindowDidEnterFullScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:nil];

    // initially the dialpad is open
    [self.viewContainer setFrame:NSMakeRect(0, 351, 310, 297)];
    [viewCurrent setFrame:NSMakeRect(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height)];
    // hide all others
    [self.recentsView setHidden:false];
    [self.dhResourcesView setHidden:true];
    [self.contactsView setHidden:true];
    [self.settingsView setHidden:true];
    
    self.callQualityIndicator = [[CallQualityIndicator alloc] initWithFrame:self.videoView.view.frame];
    [self.callView addSubview:self.callQualityIndicator];

    self.videoView = [[VideoView alloc] init];
    [self.callView addSubview:[self.videoView view]];
    [self.videoView createNumpadView];
}

- (void) viewDidAppear {
    [super viewDidAppear];
    
    [self.callQualityIndicator setWantsLayer:YES];
    [self.callQualityIndicator.layer setBackgroundColor:[NSColor clearColor].CGColor];
    [self.callQualityIndicator setBackgroundColor:[NSColor clearColor]];

    [self.recentsView reloadCallLogs];
}

#pragma mark - Observers and related functions

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didClosedSettingsWindow:)
                                                 name:@"didClosedSettingsWindow"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didClosedMessagesWindow:)
                                                 name:@"didClosedMessagesWindow"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyReceived:) name:kLinphoneNotifyReceived object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"didClosedSettingsWindow"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"didClosedMessagesWindow"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneNotifyReceived
                                                  object:nil];
}

- (void)didClosedMessagesWindow:(NSNotification*)not {
    [self.dockView clearDockViewMessagesBackgroundColor:YES];
}

- (void)didClosedSettingsWindow:(NSNotification*)not {
    [self.dockView clearDockViewSettingsBackgroundColor:YES];
}

- (void)notifyReceived:(NSNotification *)notif {
    const LinphoneContent *content = [[notif.userInfo objectForKey:@"content"] pointerValue];
    if ((content == NULL) || (strcmp("application", linphone_content_get_type(content)) != 0) ||
        (strcmp("simple-message-summary", linphone_content_get_subtype(content)) != 0) ||
        (linphone_content_get_buffer(content) == NULL)) {
        return;
    }
    
    NSInteger mwiCount;
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"sip_mwi_count"]){
        mwiCount = 0;
    }
    else{
        mwiCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"sip_mwi_count"];
    }
    mwiCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:mwiCount forKey:@"sip_mwi_count"];
    self.textFieldVoiceMailCount.stringValue = [NSString stringWithFormat:@"( %ld )", mwiCount];
    
    const char *body = linphone_content_get_buffer(content);
    if ((body = strstr(body, "voice-message: ")) == NULL) {
        return;
    }
}

#pragma mark DocView Delegate

- (void) didClickDockViewRecents:(DockView*)docView_ {
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    self.recentsView.callsSegmentControll.hidden = NO;
    viewCurrent = (BackgroundedView*)self.recentsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height)];
    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemRecents];

    [self.recentsView setHidden:false];
    [self.dhResourcesView setHidden:true];
    [self.contactsView setHidden:true];
    [self.settingsView setHidden:true];
    
    [self hideDialPad:true];

}

- (void) didClickDockViewContacts:(DockView*)docView_ {
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    viewCurrent = (BackgroundedView*)self.contactsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height)];
    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemContacts];

    
    [self.recentsView setHidden:true];
    [self.dhResourcesView setHidden:true];
    [self.contactsView setHidden:false];
    [self.settingsView setHidden:true];
    
    [self hideDialPad:true];
}

- (void) didClickDockViewDialpad:(DockView*)dockView_
{
    NSRect rect = [self.dialPadView getFrame];
    [self hideDialPad:![self.dialPadView isHidden]];
    if (self.viewContainer.frame.origin.y == 81) {
        [self.viewContainer setFrame:NSMakeRect(0, 351, 310, 297)];
        [viewCurrent setFrame:NSMakeRect(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height)];
        [self.dockView selectItemWithDocViewItem:DockViewItemDialpad];
    } else {
        [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
        [viewCurrent setFrame:NSMakeRect(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height)];
        [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
        
        if ([viewCurrent isKindOfClass:[RecentsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemRecents];
        } else if ([viewCurrent isKindOfClass:[ContactsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemContacts];
        } else if ([viewCurrent isKindOfClass:[SettingsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemSettings];
        } else if ([viewCurrent isKindOfClass:[DHResourcesView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemResources];
        }
    }
    
}

- (void) didClickDockViewResources:(DockView*)dockView_
{
    [self resourcesClicked];
}
-(void)resourcesClicked
{
    
//    ResourcesViewController *resourceViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"DHResources"];
//
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    //viewCurrent = (BackgroundedView*)resourceViewController.view;
    viewCurrent = (BackgroundedView*)self.dhResourcesView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height)];

    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemResources];
    
    [self.recentsView setHidden:true];
    [self.dhResourcesView setHidden:false];
    [self.contactsView setHidden:true];
    [self.settingsView setHidden:true];
    
    [self hideDialPad:true];
}

- (void) didClickDockViewSettings:(DockView*)dockView_ {
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    viewCurrent = (BackgroundedView*)self.settingsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height)];
    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemSettings];
    
    [self.recentsView setHidden:true];
    [self.dhResourcesView setHidden:true];
    [self.contactsView setHidden:true];
    [self.settingsView setHidden:false];
    
    [self hideDialPad:true];
}

-(void)hideDialPad:(bool)hide
{
    [self.dialPadView hideDialPad:hide];
}


- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    NSLog(@"- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector");
    return NO;
}

- (void)dealloc {
    [self removeObservers];
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
    [self.dialPadView setProvButtonImage:providerLogo];
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return providersArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    ProviderTableCellView *cellView = [tableView makeViewWithIdentifier:@"providerCell" owner:self];
    NSDictionary *dict = [providersArray objectAtIndex:row];
    NSString *imageName = [dict objectForKey:@"providerLogo"];
    [cellView.providerImageView setImage:[[NSImage alloc]initWithContentsOfFile:imageName]];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 53;
}

- (IBAction)didSelectedTableRow:(id)sender {
    NSInteger selectedRow = [self.providerTableView selectedRow];
    if (selectedRow >= 0 && selectedRow < providersArray.count) {
        NSDictionary *dict = [providersArray objectAtIndex:selectedRow];
        NSString *imageName = [dict objectForKey:@"providerLogo"];
        NSImage * providerLogo =  [[NSImage alloc] initWithContentsOfFile:imageName];
      
        [self.dialPadView setProvButtonImage:providerLogo];
        NSString *currentText = [self.dialPadView getDialerText];
        currentText = [currentText stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
        currentText = [currentText componentsSeparatedByString:@"@"][0];
        [self.dialPadView setDialerText:[NSString stringWithFormat:@"sip:%@@%@", currentText, [dict objectForKey:@"domain"]]];

        self.providersView.hidden = YES;
    }
}

- (IBAction)onVideoMailClicked:(id)sender {
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"sip_videomail_uri"]){
        NSString *videoMailUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"sip_videomail_uri"];
        [[LinphoneManager instance] call:videoMailUri displayName:@"Videomail" transfer:NO];
    }
}

- (IBAction)onButtonProv:(id)sender {
    self.providersView.hidden = !self.providersView.hidden;
    
//    NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
////    window.collectionBehavior = NSWindowCollectionBehaviorFullScreenDisallowsTiling;
//    [window toggleFullScreen:self];
}

- (IBAction)onButtonProfileImage:(id)sender {
}

- (ProfileView*) getProfileView {
    return self.profileView;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint mousePosition = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    [self mouseMovedWithPoint:mousePosition];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint mousePosition = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    [self mouseMovedWithPoint:mousePosition];
}

- (void)mouseMovedWithPoint:(NSPoint)mousePosition {
    if ([[CallService sharedInstance] getCurrentCall]) {
        LinphoneCallState call_state = linphone_call_get_state([[CallService sharedInstance] getCurrentCall]);
        
        if (self.isAppFullScreen || ((call_state != LinphoneCallDeclined && call_state != LinphoneCallEnd && call_state != LinphoneCallError) && mousePosition.x > 300 && mousePosition.x < 1030 && mousePosition.y > 0 && mousePosition.y < 700)) {
            [self.videoView setMouseInCallWindow];
        }
    }
}

- (BOOL) isCurrentTabRecents {
    return [viewCurrent isKindOfClass:[RecentsView class]];
}

- (void)windowWillEnterFullScreen:(NSNotification*)notif {
    NSLog(@"windowWillEnterFullScreen");
    
    [self.videoView windowWillEnterFullScreen];
    [(BackgroundedView*)self.view setBackgroundColor:[NSColor blackColor]];
}

- (void)windowDidEnterFullScreen:(NSNotification*)notif {
    NSLog(@"windowDidEnterFullScreen");
    
    [self.videoView windowDidEnterFullScreen];
    self.isAppFullScreen = YES;
}

- (void)windowWillExitFullScreen:(NSNotification*)notif {
    [self.videoView windowWillExitFullScreen];
    [(BackgroundedView*)self.view setBackgroundColor:windowDefaultColor];
}

- (void)windowDidExitFullScreen:(NSNotification*)notif {
    [self.videoView windowDidExitFullScreen];

    self.isAppFullScreen = NO;
}

- (void)activateMenuItems {
    [[[[NSApplication sharedApplication] delegate] menuItemFEDVRS] setAction:@selector(callToProvider:)];
    [[[[NSApplication sharedApplication] delegate] menuItemZVRS] setAction:@selector(callToProvider:)];
    [[[[NSApplication sharedApplication] delegate] menuItemPurple] setAction:@selector(callToProvider:)];
    [[[[NSApplication sharedApplication] delegate] menuItemSorenson] setAction:@selector(callToProvider:)];
    [[[[NSApplication sharedApplication] delegate] menuItemConvo] setAction:@selector(callToProvider:)];
    [[[[NSApplication sharedApplication] delegate] menuItemGlobalENus] setAction:@selector(callToProvider:)];
    [[[[NSApplication sharedApplication] delegate] menuItemGlobalENes] setAction:@selector(callToProvider:)];
    [[[[NSApplication sharedApplication] delegate] menuItemCAAG] setAction:@selector(callToProvider:)];
}

- (void)callToProvider:(NSMenuItem*)sender {
    
    NSString *phoneNumber = [[sender title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[LinphoneManager instance] call:phoneNumber displayName:[self providerNameByPhoneNumber:phoneNumber] transfer:NO];
}

- (NSString*)providerNameByPhoneNumber:(NSString*)phoneNumber {
    
    if ([phoneNumber isEqualToString:@"877-709-5797"]) {
        return @"FEDVRS";
    }
    if ([phoneNumber isEqualToString:@"888-888-1116"]) {
        return @"ZVRS";
    }
    if ([phoneNumber isEqualToString:@"877-467-4877"]) {
        return @"Purple";
    }
    if ([phoneNumber isEqualToString:@"866-327-8877"]) {
        return @"Sorenson";
    }
    if ([phoneNumber isEqualToString:@"877-363-7575"]) {
        return @"Convo";
    }
    if ([phoneNumber isEqualToString:@"888-472-6778"]) {
        return @"Global EN.us";
    }
    if ([phoneNumber isEqualToString:@"888-472-6768"]) {
        return @"Global EN.es";
    }
    if ([phoneNumber isEqualToString:@"855-877-2224"]) {
        return @"CAAG";
    }
    
    return @"N/A";
}

@end
