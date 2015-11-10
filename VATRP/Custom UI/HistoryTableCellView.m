//
//  ContactTableCellView.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/14/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "HistoryTableCellView.h"

@implementation HistoryTableCellView

- (void) setCallLog:(LinphoneCallLog*)callLog {
    // Set up the cell...
    LinphoneAddress *addr;
    NSImage *image;
    
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        if (linphone_call_log_get_status(callLog) != LinphoneCallMissed) {
            image = [NSImage imageNamed:@"call_status_incoming.png"];
        } else {
            image = [NSImage imageNamed:@"call_status_missed.png"];
        }
        addr = linphone_call_log_get_from(callLog);
    } else {
        image = [NSImage imageNamed:@"call_status_outgoing.png"];
        addr = linphone_call_log_get_to(callLog);
    }
    
    NSString *address = nil;
    if (addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        if (useLinphoneAddress) {
            const char *lDisplayName = linphone_address_get_display_name(addr);
            const char *lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if (lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    
    if (address == nil) {
        address = NSLocalizedString(@"Unknown", nil);
    }
    
    
    time_t start_date = linphone_call_log_get_start_date(callLog);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:start_date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    NSLog(@"formattedDateString: %@", formattedDateString);
    
    int duration = linphone_call_log_get_duration(callLog);
    
    [self.textFieldRemoteName setStringValue:address];
    [self.imageViewCallStatus setImage:image];
    [self.textFieldCallDate setStringValue:formattedDateString];
    [self.textFieldCallDuration setStringValue:[HistoryTableCellView timeFormatConvertToSeconds:duration]];
}

+ (NSString *)timeFormatConvertToSeconds:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
