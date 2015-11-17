//
//  ContactTableCellView.h
//  ACE
//
//  Created by Ruben Semerjyan on 10/14/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"

@interface HistoryTableCellView : NSTableCellView

- (void) setCallLog:(LinphoneCallLog*)callLog;

@property (weak) IBOutlet NSImageView *imageViewCallStatus;
@property (weak) IBOutlet NSTextField *textFieldRemoteName;
@property (weak) IBOutlet NSTextField *textFieldCallDate;
@property (weak) IBOutlet NSTextField *textFieldCallDuration;

@end
