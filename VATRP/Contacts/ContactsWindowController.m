//
//  ContactsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "ContactsWindowController.h"

@interface ContactsWindowController ()

@end

@implementation ContactsWindowController

@synthesize isShow;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    NSString *content = @"FILE SYSTEM VCARD 3.0.";
    NSString *filePath = @"/Users/zackmatthews/github.com/accounts/vtcsecure/ace-mac/contact.vcard";
    NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:fileContents
                                          attributes:nil];
    
    
    NSError *error = nil;
    NSString *retrievedContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    NSLog(@"vCard info = %@", retrievedContent);
}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
}

@end
