//
//  ProviderNumberTableCellView.m
//  ACE
//
//  Created by Mac on 1/27/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "ProviderNumberTableCellView.h"

@implementation ProviderNumberTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (void)setupCellWithProviderInfo:(NSDictionary *)providerInfo {
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"FEDVRS"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@""]];
    }
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"ZVRS"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@"provider_logo_zvrs"]];
    }
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"Purple"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@"provider_logo_purplevrs"]];
    }
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"Sorenson"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@"provider_logo_sorenson"]];
    }
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"Convo"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@"provider_logo_convorelay"]];
    }
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"Global EN.us"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@"provider_logo_globalvrs"]];
    }
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"Global EN.es"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@"provider_logo_globalvrs"]];
    }
    
    if ([[providerInfo objectForKey:@"name"] isEqualToString:@"CAAG"]) {
        [self.providerImageView setImage:[NSImage imageNamed:@"provider_logo_caag"]];
    }
    
    [self.numberLabel setStringValue:[providerInfo objectForKey:@"phone"]];
}

@end
