//
//  ProfileView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundedViewController.h"

@interface ProfileView : BackgroundedViewController

- (void)registrationUpdateEvent:(NSNotification*)notif;
-(void) updateVoiceMailIndicator:(NSInteger)mwiCount;
@end
