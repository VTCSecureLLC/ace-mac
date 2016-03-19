//
//  SettingsWindowController.h
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsWindowController : NSWindowController

@property (nonatomic, assign) BOOL isShow;

// note: 10.9 - viewWillAppear not being called. using explicit initialization to keep code a little cleaner (fewer if defs)
-(void) initializeData;
- (void) addPreferencesToolbarItem;
-(void)closeWindow;
@end
