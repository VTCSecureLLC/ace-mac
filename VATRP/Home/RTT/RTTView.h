//
//  RTTView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/25/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "BackgroundedViewController.h"

@interface RTTView : BackgroundedViewController

-(void)clearData;

- (void) setCustomFrame:(NSRect)frame;

- (void) updateViewForDisplay;

// we want the observers to be added when we are in call, removed if we are not in a call.
-(void) addInCallObservers;
-(void) removeObservers;


@end
