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

@protocol SettingsSelfViewDelegate<NSObject>
#pragma mark items for settingsSelfViewDelegate - setting from settings dialog to responders
-(void)showSelfViewFromSettings:(bool)mute;
@end

@protocol InCallPreferencesHandlerDelegate<NSObject>
#pragma mark items for preferencesHandlerDelegate - setting from settings dialog to responders
-(void)cameraWasMuted:(bool)enabled;
@end

@protocol PreferencesHandlerDelegate<NSObject>
#pragma mark items for preferencesHandlerDelegate - setting from settings dialog to responders
-(void)muteCamera:(bool)enable;
@end


@interface SettingsHandler : NSObject
+ (id)settingsHandler;

@property(weak,nonatomic)id<InCallSettingsDelegate> inCallSettingsDelegate;
@property(weak,nonatomic)id<SettingsHandlerDelegate> settingsHandlerDelegate;
@property(weak,nonatomic)id<InCallPreferencesHandlerDelegate> inCallPreferencessHandlerDelegate;
@property(weak,nonatomic)id<PreferencesHandlerDelegate> preferencessHandlerDelegate;
@property(weak,nonatomic)id<SettingsSelfViewDelegate> settingsSelfViewDelegate;

// Bool force provided for debugging, and to reset settings when needed.
-(void) initializeUserDefaults:(bool)force;
-(void) resetDefaultsWithCoreRunning;

#pragma mark items for inCallSettingsDelegate - setting from call window to settings dialog
-(void) inCallSpeakerWasMuted:(bool)mute;
-(void) inCallMicrophoneWasMuted:(bool)mute;
-(void) inCallShowSelfView:(bool)shown;
//-(void) inCallMuteCamera:(bool)enable;


#pragma mark items for settingsHandlerDelegate - setting from settings dialog to responders
-(void) setMuteSpeaker:(bool)mute;
-(void) setMuteMicrophone:(bool)mute;
-(void) setShowSelfView:(bool)show;
-(void) setShowVideoSelfPreview:(bool)show;
-(void) setEnableEchoCancellation:(bool)show;
-(void) setMuteCamera:(bool)enable;

-(void) setEnableVideo:(bool)enable;
-(void) setVideoInitiate:(bool)enable;
-(void) setVideoAccept:(bool)enable;

- (void)setQoSEnable:(BOOL)enableQos;
- (void)setQoSSignalingValue:(int)signalingValue;
- (void)setQoSAudioValue:(int)audioValue;
- (void)setQoSVideoValue:(int)videoValue;

- (void)setStunServerDomain:(NSString*)stunServerDomain;

#pragma mark settings accessors
// these settings are set when the UI calls one of the methods above.
-(bool)isSpeakerMuted;
-(bool)isMicrophoneMuted;
-(bool)isEchoCancellationEnabled;
-(bool)isShowSelfViewEnabled;
-(bool)isShowPreviewEnabled;
//-(bool)isMuteCamera;

-(bool)isVideoEnabled;
- (BOOL)isQosEnabled;

#pragma mark Media Settings
-(NSString*)getSelectedCamera;
-(NSString*)getSelectedMicrophone;
-(NSString*)getSelectedSpeaker;
-(float)getPreferredFPS;

-(void)setSelectedCamera:(NSString*)cameraName;
-(void)setSelectedMicrophone:(NSString*)microphoneName;
-(void)setSelectedSpeaker:(NSString*)speakerName;
-(void)setPreferredFPS:(float)preferredFPS;

#pragma mark Testing Settings
-(void)setRtcpFbMode:(NSString*) rtcpFbMode;
-(NSString*)getRtcpFbMode;

-(int)getUploadBandwidth;
-(void)setUploadBandwidth:(int)bandwidth;

-(int)getDownloadBandwidth;
-(void)setDownloadBandwidth:(int)bandwidth;

#pragma mark app settings
-(bool) isAdaptiveRateControlEnabled;
-(NSString*) getAdaptiveRateAlgorithm;
-(NSString*) getVideoPreset;
-(NSString*) getStunServerDomain;
-(NSString*)setStunServerDomain;
@end
#endif /* SettingsDelegate_h */
