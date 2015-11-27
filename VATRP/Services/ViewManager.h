//
//  ViewManager.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DockView.h"
#import "DialPadView.h"
#import "ProfileView.h"
#import "RecentsView.h"
#import "RTTView.h"


#define DIALPAD_TEXT_CHANGED @"DIALPAD_TEXT_CHANGED"

@interface ViewManager : NSObject

+ (ViewManager *)sharedInstance;

@property (nonatomic, retain) DockView *dockView;
@property (nonatomic, retain) DialPadView *dialPadView;
@property (nonatomic, retain) ProfileView *profileView;
@property (nonatomic, retain) RecentsView *recentsView;
@property (nonatomic, retain) NSView *callView;
@property (nonatomic, retain) RTTView *rttView;

@end
