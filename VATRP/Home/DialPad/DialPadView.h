//
//  DialPadView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundedView.h"

@interface DialPadView : BackgroundedView <NSTextFieldDelegate>

-(void)setProvButtonImage:(NSImage*)img;

-(void)setDialerText:(NSString*) address;
-(NSString*)getDialerText;
@end
