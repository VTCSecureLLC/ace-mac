//
//  ContactTableCellView.h
//  ACE
//
//  Created by Ruben Semerjyan on 10/14/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ContactTableCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *textFieldInitials;
@property (weak) IBOutlet NSTextField *textFieldLastMessage;

@end
