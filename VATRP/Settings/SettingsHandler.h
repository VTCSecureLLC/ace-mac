//
//  SettingsDelegate.h
//  ACE
//
//  Created by Lizann Epley on 2/1/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#ifndef SettingsDelegate_h
#define SettingsDelegate_h

#import <Foundation/Foundation.h>

@protocol SettingsDelegate<NSObject>
// selectors
-(void)muteSpeaker:(bool)mute;
@end

@interface SettingsHandler : NSObject
+ (id)settingsHandler;


@property(weak,nonatomic)id<SettingsDelegate> delegate;

-(void)setMuteSpeaker:(bool)mute;

@end


#endif /* SettingsDelegate_h */
