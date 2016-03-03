//
//  SettingsContants.m
//  ACE
//
//  Created by Lizann Epley on 2/2/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#ifndef SettingsConstants_h
#define SettingsConstants_h

#import <Foundation/Foundation.h>

// AV Settings
NSString *const MUTE_SPEAKER = @"SPEAKER_MUTE";
NSString *const MUTE_MICROPHONE = @"MICROPHONE_MUTE";
NSString *const ENABLE_ECHO_CANCELLATION = @"enable_echo_cancellation";
NSString *const VIDEO_SHOW_SELF_VIEW = @"VIDEO_SHOW_SELF_VIEW";
NSString *const VIDEO_SHOW_PREVIEW = @"VIDEO_SHOW_PREVIEW";


// Media settings
NSString *const SELECTED_CAPTURE_DEVICE = @"SETTINGS_SELECTED_CAPTURE_DEVICE";
NSString *const SELECTED_MICROPHONE = @"SETTINGS_SELECTED_MICROPHONE";
NSString *const SELECTED_SPEAKER = @"SETTINGS_SELECTED_SPEAKER";

// Video Settings
NSString *const ENABLE_VIDEO = @"enable_video_preference";
NSString *const ENABLE_VIDEO_START = @"start_video_preference";
NSString *const ENABLE_VIDEO_ACCEPT = @"accept_video_preference";
NSString *const PREFERRED_FPS = @"video_preferred_fps_preference";
NSString *const PREFERRED_VIDEO_RESOLUTION = @"video_preferred_size_preference";

// Preferences
NSString *const MUTE_CAMERA = @"mute_camera";
NSString *const RTCP_FB_MODE = @"RTCP_FB_MODE"; //Off (Default), Implicit, Explicit

// testing
NSString *const UPLOAD_BANDWIDTH = @"upload_bandwidth";
NSString *const DOWNLOAD_BANDWIDTH = @"download_bandwidth";
NSString *const ENABLE_QoS = @"enable_QoS";
NSString *const STUN_SERVER_DOMAIN = @"stun_url_preference";

// app settings
NSString *const ADAPTIVE_RATE_ALGORITHM = @"adaptive_rate_algorithm";
NSString *const ADAPTIVE_RATE_CONTROL = @"enable_adaptive_rate_control";
NSString *const VIDEO_PRESET = @"video_preset";

#endif /* SettingsConstants_h */