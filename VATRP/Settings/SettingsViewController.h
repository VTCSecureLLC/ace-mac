//
//  SettingsViewController.h
//  ACE
//
//  Created by Edgar Sukiasyan on 9/30/15.
//  Copyright © 2015 Home. All rights reserved.
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