//
//  ViewManager.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocView.h"
#import "DialPadView.h"
#import "ProfileView.h"
#import "RecentsView.h"


#define DIALPAD_TEXT_CHANGED @"DIALPAD_TEXT_CHANGED"

@interface ViewManager : NSObject

+ (ViewManager *)sharedInstance;

@property (nonatomic, retain) DocView *docView;
@property (nonatomic, retain) DialPadView *dialPadView;
@property (nonatomic, retain) ProfileView *profileView;
@property (nonatomic, retain) RecentsView *recentsView;

@end
