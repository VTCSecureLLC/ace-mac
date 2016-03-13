//
//  AddContactWindowController.h
//  ACE
//
//  Created by Lizann Epley on 3/12/16.
//  Copyright (c) 2016 VTCSecure. All rights reserved.
//

#ifndef ACE_AddContactWindowController_h
#define ACE_AddContactWindowController_h
#import <Cocoa/Cocoa.h>


@interface AddContactWindowController : NSWindowController
-(void)setIsEditing:(bool)isEditing;
-(void)initializeDataWith:(bool)isEditing oldName:(NSString*)oldName oldPhone:(NSString*)oldPhone oldProviderName:(NSString*)oldProviderName;

@end

#endif
