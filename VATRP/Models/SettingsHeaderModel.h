//
//  SettingsHeaderModel.h
//  ACE
//
//  Created by Norayr Harutyunyan on 12/8/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsHeaderModel : NSObject

- (id) initWithTitle:(NSString*)ttl;

@property (nonatomic, retain) NSString *title;

@end
