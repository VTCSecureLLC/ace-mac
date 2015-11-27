//
//  AddContactDialogBox.h
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddContactDialogBox : NSViewController

@property (strong, nonatomic) NSString *nameString;
@property (strong, nonatomic) NSString *phoneString;
@property BOOL isEditing;
@end
