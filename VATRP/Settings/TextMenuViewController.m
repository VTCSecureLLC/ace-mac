//
//  TextMenuViewController
//  ACE
//
//  Created by Patrick Watson on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "TextMenuViewController.h"
#import "SettingsService.h"
#import "LinphoneManager.h"

@interface TextMenuViewController () {
    BOOL isChanged;
}

@property (weak) IBOutlet NSButton *enable_text;
@property (weak) IBOutlet NSComboBox *text_send_mode;
@property (weak) IBOutlet NSPopUpButton *fontsPopUpButton;

@end

@implementation TextMenuViewController

-(id) init
{
    self = [super initWithNibName:@"TextMenuViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Do view setup here.
    [self initializeData];
}

-(void)initializeData
{
    self.enable_text.state = [SettingsService getRTTEnabled];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"TEXT_SEND_MODE"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"Real Time Text (RTT)" forKey:@"TEXT_SEND_MODE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.text_send_mode.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"TEXT_SEND_MODE"];
    self.text_send_mode.enabled = NO;
    
    isChanged = NO;
    [self initFontFamilies];
}

- (void)initFontFamilies {
    
    NSArray *systemFonts = [[NSFontManager sharedFontManager] availableFontFamilies];
    NSMenu *menu = [NSMenu new];
    for (NSString *family in systemFonts) {
        NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:family size:[NSFont systemFontSize]],NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName,nil];
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:family];
        [aString addAttributes:attr range:NSMakeRange(0, [aString length])];
        NSMenuItem *item = [NSMenuItem new];
        [item setAttributedTitle:aString];
        [menu addItem:item];
    }
    [self.fontsPopUpButton setMenu:menu];
    NSString *currentRttFontName = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"rttFontName"]) {
        NSString *storedRttFontName = [[NSUserDefaults standardUserDefaults] stringForKey:@"rttFontName"];
        currentRttFontName = storedRttFontName;
    } else {
        currentRttFontName = @"Helvetica";
    }
    
    [self.fontsPopUpButton setTitle:currentRttFontName];
}

- (IBAction)onCheckBoxEnableText:(id)sender {
    isChanged = YES;
    NSLog(@"CHECKED");
}

- (IBAction)onComboBoxTextSendMode:(id)sender {
    isChanged = YES;
     NSLog(@"SEND MODE");
}

- (IBAction)onFontBoxTap:(id)sender {
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.enable_text.state forKey:kREAL_TIME_TEXT_ENABLED];
    //[[NSUserDefaults standardUserDefaults] setBool:self.enable_text.state forKey:@"ENABLE_TEXT"];
    [[NSUserDefaults standardUserDefaults] setObject:self.text_send_mode.stringValue forKey:@"TEXT_SEND_MODE"];
   
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* text_mode_string=[defaults stringForKey:@"TEXT_SEND_MODE"];
    NSLog(@"SEND MODE %@",text_mode_string);
    
    NSMenuItem *selectedRttFontItem = self.fontsPopUpButton.selectedItem;
    [[NSUserDefaults standardUserDefaults] setObject:selectedRttFontItem.title forKey:@"rttFontName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
