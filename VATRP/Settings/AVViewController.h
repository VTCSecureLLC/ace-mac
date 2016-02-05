//
//  AVViewController.h
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SettingsHandler.h"

@interface AVViewController : NSViewController<InCallSettingsDelegate>

- (void) save;

@end
