//
//  AddContactDialogBox.h
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddContactDialogBox : NSViewController

@property (strong, nonatomic) NSString *oldName;
@property (strong, nonatomic) NSString *oldPhone;
@property (strong, nonatomic) NSString *oldProviderName;
@property (strong, nonatomic) NSString *refKey;
@property BOOL isEditing;

-(void) initializeData;
@end
