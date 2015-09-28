//
//  CodecsViewController.m
//  ACE
//
//  Created by Edgar Sukiasyan on 9/28/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "CodecsViewController.h"
#import "LinphoneManager.h"
#import "CodecModel.h"

@interface CodecsViewController () <NSTableViewDataSource> {
    IBOutlet NSTableView *tableViewAudioCodecs;
    IBOutlet NSTableView *tableViewVideoCodecs;
    
    NSMutableArray *audioCodecList;
    NSMutableArray *videoCodecList;
}

- (CodecModel*) getCodecWithName:(NSString*)name;

@end

@implementation CodecsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
//    codecList = [[NSMutableArray alloc] init];
//    codecModel = [[CodecModel alloc] init];
//    [codecList addObject:codecModel];
//    codecModel = [[CodecModel alloc] init];
//    codecModel.status = NO;
//    [codecList addObject:codecModel];
//    codecModel = [[CodecModel alloc] init];
//    [codecList addObject:codecModel];
//    codecModel = [[CodecModel alloc] init];
//    codecModel.status = NO;
//    [codecList addObject:codecModel];
    
    audioCodecList = [[NSMutableArray alloc] init];
    videoCodecList = [[NSMutableArray alloc] init];
    
    LinphoneCore *lc = [LinphoneManager getLc];
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            bool_t value = linphone_core_payload_type_enabled(lc, pt);

            CodecModel *codecModel = [[CodecModel alloc] init];
            
            codecModel.name = [NSString stringWithUTF8String:pt->mime_type];
            codecModel.rate = pt->clock_rate;
            codecModel.channels = pt->channels;
            codecModel.status = value;

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
            codecModel.rate = pt->clock_rate;
            codecModel.channels = pt->channels;
            codecModel.status = value;
            
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
}

- (IBAction)onCheckboxVideoStatus:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    NSInteger row = [tableViewVideoCodecs rowForView:button];
    CodecModel *codecModel = [videoCodecList objectAtIndex:row];
    codecModel.status = button.state;
}

- (IBAction)onButtonSave:(id)sender {
    LinphoneCore *lc = [LinphoneManager getLc];
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getCodecWithName:[NSString stringWithUTF8String:pt->mime_type]];
            
            if (codecModel) {
                linphone_core_enable_payload_type(lc, pt, codecModel.status);
            }
        }
    }

    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);

    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getCodecWithName:[NSString stringWithUTF8String:pt->mime_type]];
            
            if (codecModel) {
                linphone_core_enable_payload_type(lc, pt, codecModel.status);
            }
        }
    }
}

- (CodecModel*) getCodecWithName:(NSString*)name {
    for (CodecModel *codecModel in audioCodecList) {
        if ([codecModel.name isEqualToString:name]) {
            return codecModel;
        }
    }

    for (CodecModel *codecModel in videoCodecList) {
        if ([codecModel.name isEqualToString:name]) {
            return codecModel;
        }
    }
    
    return nil;
}

@end
