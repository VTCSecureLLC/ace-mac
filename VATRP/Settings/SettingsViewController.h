//
//  SettingsViewController.h
//  ACE
//
//  Created by Ruben Semerjyan on 9/30/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : NSViewController

@property (nonatomic, assign) id<SettingsViewControllerDelegate> delegate;

@end

@protocol SettingsViewControllerDelegate <NSObject>

@optional

- (void) didClickSettingsViewControllerSeve:(SettingsViewController*)settingsViewController;

@end