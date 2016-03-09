//
//  DialPadView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundedViewController.h"

@interface DialPadView : BackgroundedViewController <NSTextFieldDelegate>

-(void)setProvButtonImage:(NSImage*)img;

-(void)setDialerText:(NSString*) address;
-(NSString*)getDialerText;

-(void)hideDialPad:(bool)hidden;
@end
