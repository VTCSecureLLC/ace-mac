//
//  ThemeMenuViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "ThemeMenuViewController.h"
#import "SettingsService.h"

@interface ThemeMenuViewController () {
    BOOL isChanged;
}

@property (weak) IBOutlet NSColorWell *colorWellForeground;
@property (weak) IBOutlet NSColorWell *colorWellBackground;
@property (weak) IBOutlet NSButton *buttonForce508;

@end

@implementation ThemeMenuViewController

-(id) init
{
    self = [super initWithNibName:@"ThemeViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    isChanged = NO;
}

- (void) viewWillAppear {
    [super viewWillAppear];
    
    NSColor *color = [SettingsService getColorWithKey:@"APP_FOREGROUND_COLOR"];
    [self.colorWellForeground setColor:color ? color : [NSColor whiteColor]];
    color = [SettingsService getColorWithKey:@"APP_BACKGROUND_COLOR"];
    [self.colorWellBackground setColor:color ? color : [NSColor whiteColor]];
    self.buttonForce508.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"APP_FORCE_508"];
}

- (IBAction)onColorForeground:(id)sender {
    isChanged = YES;
}

- (IBAction)onColorBackground:(id)sender {
    isChanged = YES;
}

- (IBAction)onCheckBoxForce508:(id)sender {
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [SettingsService setColorWithKey:@"APP_FOREGROUND_COLOR" Color:self.colorWellForeground.color];
    [SettingsService setColorWithKey:@"APP_BACKGROUND_COLOR" Color:self.colorWellBackground.color];
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonForce508.state forKey:@"APP_FORCE_508"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
