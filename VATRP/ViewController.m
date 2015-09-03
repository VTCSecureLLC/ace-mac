//
//  ViewController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "ViewController.h"
#import "ContactsWindowController.h"
#import "RecentsWindowController.h"
#import "DialpadWindowController.h"
#import "VideoMailWindowController.h"
#import "SettingsWindowController.h"


@interface ViewController () {
    
}

@property (nonatomic, retain) ContactsWindowController *contactsWindowController;
@property (nonatomic, retain) RecentsWindowController *recentsWindowController;
@property (nonatomic, retain) DialpadWindowController *dialpadWindowController;
@property (nonatomic, retain) VideoMailWindowController *videoMailWindowController;
@property (nonatomic, retain) SettingsWindowController *settingsWindowController;

- (IBAction)onButtonRecents:(id)sender;
- (IBAction)onButtonContacts:(id)sender;
- (IBAction)onButtonDialpad:(id)sender;
- (IBAction)onButtonVidelMail:(id)sender;
- (IBAction)onButtonSettings:(id)sender;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onButtonRecents:(id)sender {
    if (!self.recentsWindowController) {
        self.recentsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Recents"];
        [self.recentsWindowController showWindow:self];
    } else {
        if (self.recentsWindowController.isShow) {
            [self.recentsWindowController close];
        } else {
            [self.recentsWindowController showWindow:self];
            self.recentsWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonContacts:(id)sender {
    if (!self.contactsWindowController) {
        self.contactsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Contacts"];
        [self.contactsWindowController showWindow:self];
    } else {
        if (self.contactsWindowController.isShow) {
            [self.contactsWindowController close];
        } else {
            [self.contactsWindowController showWindow:self];
            self.contactsWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonDialpad:(id)sender {
    if (!self.dialpadWindowController) {
        self.dialpadWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Dialpad"];
        [self.dialpadWindowController showWindow:self];
    } else {
        if (self.dialpadWindowController.isShow) {
            [self.dialpadWindowController close];
        } else {
            [self.dialpadWindowController showWindow:self];
            self.dialpadWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonVidelMail:(id)sender {
    if (!self.videoMailWindowController) {
        self.videoMailWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"VideoMail"];
        [self.videoMailWindowController showWindow:self];
    } else {
        if (self.videoMailWindowController.isShow) {
            [self.videoMailWindowController close];
        } else {
            [self.videoMailWindowController showWindow:self];
            self.videoMailWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonSettings:(id)sender {
    if (!self.settingsWindowController) {
        self.settingsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Settings"];
        [self.settingsWindowController showWindow:self];
    } else {
        if (self.settingsWindowController.isShow) {
            [self.settingsWindowController close];
        } else {
            [self.settingsWindowController showWindow:self];
            self.settingsWindowController.isShow = YES;
        }
    }
}

@end
