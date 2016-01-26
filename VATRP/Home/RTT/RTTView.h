//
//  RTTView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/25/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "BackgroundedView.h"

@interface RTTView : BackgroundedView
- (void) viewWillAppear;
- (void) viewWillDisappear;
- (void) setCustomFrame:(NSRect)frame;
@end
