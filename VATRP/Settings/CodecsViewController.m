//
//  CodecsViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/28/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CodecsViewController.h"
#import "LinphoneManager.h"
#import "CodecModel.h"

#define kUSER_DEFAULTS_AUDIO_CODECS_MAP @"kUSER_DEFAULTS_AUDIO_CODECS_MAP"
#define kUSER_DEFAULTS_VIDEO_CODECS_MAP @"kUSER_DEFAULTS_VIDEO_CODECS_MAP"

@interface CodecsViewController () <NSTableViewDataSource> {
    IBOutlet NSTableView *tableViewAudioCodecs;
    IBOutlet NSTableView *tableViewVideoCodecs;
    
    NSMutableArray *audioCodecList;
    NSMutableArray *videoCodecList;

    BOOL isChanged;
}

- (void) saveAudioCodecs;
- (void) saveVideoCodecs;
- (CodecModel*) getAudioCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels;
- (CodecModel*) getVideoCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels;

@end

@implementation CodecsViewController

- (void) awakeFromNib {
    [super awakeFromNib];
    
    isChanged = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    LinphoneCore *lc = [LinphoneManager getLc];
    PayloadType *pt;
    const MSList *elem;
    
    audioCodecList = [[NSMutableArray alloc] init];
    videoCodecList = [[NSMutableArray alloc] init];

    NSDictionary *dictAudioCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_AUDIO_CODECS_MAP];
    NSDictionary *dictVideoCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_VIDEO_CODECS_MAP];
    
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            bool_t value = linphone_core_payload_type_enabled(lc, pt);
            
            CodecModel *codecModel = [[CodecModel alloc] init];
            
            codecModel.name = [NSString stringWithUTF8String:pt->mime_type];
            codecModel.preference = pref;
            codecModel.rate = pt->clock_rate;
            codecModel.channels = pt->channels;
            
            if ([dictAudioCodec objectForKey:pref]) {
                codecModel.status = [[dictAudioCodec objectForKey:pref] boolValue];
            } else {
                codecModel.status = value;
            }
            
            [audioCodecList addObject:codecModel];
        }
    }
    
    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
    
    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            bool_t value = linphone_core_payload_type_enabled(lc, pt);
            
            CodecModel *codecModel = [[CodecModel alloc] init];
            
            codecModel.name = [NSString stringWithUTF8String:pt->mime_type];
            codecModel.preference = pref;
            codecModel.rate = pt->clock_rate;
            codecModel.channels = pt->channels;

            if ([dictVideoCodec objectForKey:pref]) {
                codecModel.status = [[dictVideoCodec objectForKey:pref] boolValue];
            } else {
                codecModel.status = value;
            }

            [videoCodecList addObject:codecModel];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == tableViewAudioCodecs) {
        return audioCodecList.count;
    } else if (tableView == tableViewVideoCodecs) {
        return videoCodecList.count;
    }
    
    return 0;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    CodecModel *codecModel;
    
    if (tableView == tableViewAudioCodecs) {
        codecModel = [audioCodecList objectAtIndex:row];
    } else if (tableView == tableViewVideoCodecs) {
        codecModel = [videoCodecList objectAtIndex:row];
    }

    return [codecModel valueForKey:identifier];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30;
}

- (IBAction)onCheckboxAudioStatus:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    NSInteger row = [tableViewAudioCodecs rowForView:button];
    CodecModel *codecModel = [audioCodecList objectAtIndex:row];
    codecModel.status = button.state;
    
    isChanged = YES;
}

- (IBAction)onCheckboxVideoStatus:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    NSInteger row = [tableViewVideoCodecs rowForView:button];
    CodecModel *codecModel = [videoCodecList objectAtIndex:row];
    codecModel.status = button.state;

    
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }

    [self saveAudioCodecs];
    [self saveVideoCodecs];
}

- (void) saveAudioCodecs {
    LinphoneCore *lc = [LinphoneManager getLc];
    PayloadType *pt;
    const MSList *elem;
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] init];
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getAudioCodecWithName:[NSString stringWithUTF8String:pt->mime_type]
                                                            Rate:pt->clock_rate
                                                        Channels:pt->channels];
            
            if (codecModel) {
                linphone_core_enable_payload_type(lc, pt, codecModel.status);
                
                [mdictForSave setObject:[NSNumber numberWithBool:codecModel.status] forKey:codecModel.preference];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:kUSER_DEFAULTS_AUDIO_CODECS_MAP];
}

- (void) saveVideoCodecs {
    LinphoneCore *lc = [LinphoneManager getLc];
    PayloadType *pt;
    const MSList *elem;
    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
    NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] init];
    
    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getVideoCodecWithName:[NSString stringWithUTF8String:pt->mime_type]
                                                            Rate:pt->clock_rate
                                                        Channels:pt->channels];
            
            if (codecModel) {
                linphone_core_enable_payload_type(lc, pt, codecModel.status);

                [mdictForSave setObject:[NSNumber numberWithBool:codecModel.status] forKey:codecModel.preference];
            }
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:kUSER_DEFAULTS_VIDEO_CODECS_MAP];
}

- (CodecModel*) getAudioCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels {
    for (CodecModel *codecModel in audioCodecList) {
        if ([codecModel.name isEqualToString:name] &&
            codecModel.rate == rate &&
            codecModel.channels == channels) {
            return codecModel;
        }
    }
    
    return nil;
}

- (CodecModel*) getVideoCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels {
    for (CodecModel *codecModel in videoCodecList) {
        if ([codecModel.name isEqualToString:name] &&
            codecModel.rate == rate &&
            codecModel.channels == channels) {
            return codecModel;
        }
    }
    
    return nil;
}

@end
