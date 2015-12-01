//
//  SecondCallView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/27/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "BackgroundedView.h"
#import "CallService.h"

@interface SecondCallView : BackgroundedView

@property (nonatomic, assign) LinphoneCall* call;

@end
