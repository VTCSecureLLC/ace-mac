//
//  ProviderNumberTableCellView.h
//  ACE
//
//  Created by Mac on 1/27/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProviderNumberTableCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField *numberLabel;
@property (nonatomic, weak) IBOutlet NSImageView *providerImageView;

- (void)setupCellWithProviderInfo:(NSDictionary*)providerInfo;
@end
