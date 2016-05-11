//
//  DialPadView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundedViewController.h"

@interface DialPadView : BackgroundedViewController <NSTextFieldDelegate,NSTableViewDelegate, NSTableViewDataSource>

-(void)setProvButtonImage:(NSImage*)img;

-(void)setDialerText:(NSString*) address;
-(NSString*)getDialerText;

-(void)hideDialPad:(bool)hidden;
-(bool)isHidden;

-(void)hideProvidersView:(bool)hide;

@property (weak) IBOutlet NSTextField *textFieldNumber;

@end
