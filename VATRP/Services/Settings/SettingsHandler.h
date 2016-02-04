//
//  SettingsDelegate.h
//  ACE
//
//  Created by Lizann Epley on 2/1/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#ifndef SettingsHandler_h
#define SettingsHandler_h

#import <Foundation/Foundation.h>

// This is meant to coordinate with the SettingsService class.
// Items that are currently handled directly through Settings service but we will need as account settings:
// RTTEnabled
// TextMode

@protocol InCallSettingsDelegate<NSObject>
#pragma mark items for inCallSettingsDelegate - setting from call window to settings dialog
-(void) speakerWasMuted:(bool)mute;
-(void) microphoneWasMuted:(bool)mute;
//-(void)selfViewShown:(bool)shown;
@end


@protocol SettingsHandlerDelegate<NSObject>
#pragma mark items for settingsHandlerDelegate - setting from settings dialog to responders
-(void)muteSpeaker:(bool)mute;
-(void)muteMicrophone:(bool)mute;
//-(void)showSelfView:(bool)mute;
@end

@protocol InCallPreferencesHandlerDelegate<NSObject>
#pragma mark items for preferencesHandlerDelegate - setting from settings dialog to responders
@end

@protocol PreferencesHandlerDelegate<NSObject>
#pragma mark items for preferencesHandlerDelegate - setting from settings dialog to responders
@end


@interface SettingsHandler : NSObject
+ (id)settingsHandler;

@property(weak,nonatomic)id<InCallSettingsDelegate> inCallSettingsDelegate;
@property(weak,nonatomic)id<SettingsHandlerDelegate> settingsHandlerDelegate;
@property(weak,nonatomic)id<InCallPreferencesHandlerDelegate> inCallPreferencessHandlerDelegate;
@property(weak,nonatomic)id<PreferencesHandlerDelegate> preferencessHandlerDelegate;

-(void)initializeUserDefaults;


#pragma mark items for inCallSettingsDelegate - setting from call window to settings dialog
-(void) inCallSpeakerWasMuted:(bool)mute;
-(void) inCallMicrophoneWasMuted:(bool)mute;
-(void) inCallShowSelfView:(bool)shown;



#pragma mark items for settingsHandlerDelegate - setting from settings dialog to responders
-(void) setMuteSpeaker:(bool)mute;
-(void) setMuteMicrophone:(bool)mute;
-(void) setShowSelfView:(bool)show;
-(void) setEnableEchoCancellation:(bool)show;

-(void) setEnableVideo:(bool)enable;


#pragma mark settings accessors
// these settings are set when the UI calls one of the methods above.
-(bool)isSpeakerMuted;
-(bool)isMicrophoneMuted;
-(bool)isEchoCancellationEnabled;
-(bool)isShowSelfViewEnabled;
-(bool)isShowPreviewEnabled;

-(bool)isVideoEnabled;

#pragma mark Media Settings
-(NSString*)getSelectedCamera;
-(NSString*)getSelectedMicrophone;
-(NSString*)getSelectedSpeaker;

-(void)setSelectedCamera:(NSString*)cameraName;
-(void)setSelectedMicrophone:(NSString*)microphoneName;
-(void)setSelectedSpeaker:(NSString*)speakerName;



@end
#endif /* SettingsDelegate_h */
