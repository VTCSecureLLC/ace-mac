//
//  SettingsConstants.h
//  ACE
//
//  Created by Lizann Epley on 2/2/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#ifndef SettingsConstants_h
#define SettingsConstants_h

#import <Foundation/Foundation.h>

// AV Settings Items
FOUNDATION_EXPORT NSString *const MUTE_SPEAKER;
FOUNDATION_EXPORT NSString *const MUTE_MICROPHONE;
FOUNDATION_EXPORT NSString *const ENABLE_ECHO_CANCELLATION;
FOUNDATION_EXPORT NSString *const VIDEO_SHOW_SELF_VIEW;
FOUNDATION_EXPORT NSString *const VIDEO_SHOW_PREVIEW;


// Media Settings
FOUNDATION_EXPORT NSString *const SELECTED_CAPTURE_DEVICE;
FOUNDATION_EXPORT NSString *const SELECTED_MICROPHONE;
FOUNDATION_EXPORT NSString *const SELECTED_SPEAKER;

// Video Settings
FOUNDATION_EXPORT NSString *const ENABLE_VIDEO;
FOUNDATION_EXPORT NSString *const ENABLE_VIDEO_START;
FOUNDATION_EXPORT NSString *const ENABLE_VIDEO_ACCEPT;
FOUNDATION_EXPORT NSString *const PREFERRED_FPS;
FOUNDATION_EXPORT NSString *const PREFERRED_VIDEO_RESOLUTION; 

// Testing Settings
FOUNDATION_EXPORT NSString *const RTCP_FB_MODE;
FOUNDATION_EXPORT NSString *const UPLOAD_BANDWIDTH;
FOUNDATION_EXPORT NSString *const DOWNLOAD_BANDWIDTH;

// Preferences
FOUNDATION_EXPORT NSString *const MUTE_CAMERA;


#endif /* SettingsConstants_h */
