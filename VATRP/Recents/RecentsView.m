//
//  RecentsView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "RecentsView.h"
#import "HistoryTableCellView.h"
#import "LinphoneManager.h"
#import "ViewManager.h"


@interface RecentsView () {
    NSMutableArray *callLogs;
    BOOL missedFilter;
    
    NSString *dialPadFilter;
}

@property (weak) IBOutlet NSScrollView *scrollViewRecents;
@property (weak) IBOutlet NSTableView *tableViewRecents;

@end

@implementation RecentsView


- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self setBackgroundColor:[NSColor clearColor]];
    
    callLogs = [[NSMutableArray alloc] init];
    missedFilter = false;
    dialPadFilter = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdate:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dialpadTextUpdate:)
                                                 name:DIALPAD_TEXT_CHANGED
                                               object:nil];
    
    [self loadData];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)callUpdate:(NSNotification*)notif {
    LinphoneCall *aCall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    
    switch (state) {
        case LinphoneCallError:
        case LinphoneCallEnd:
        case LinphoneCallReleased: {
            [self loadData];
        }
            break;
        default:
            break;
    }
}

- (void)dialpadTextUpdate:(NSNotification*)notif {
    NSString *dialpadText = [notif object];

    NSLog(@"dialpadText: %@", dialpadText);
    
    if (dialpadText && dialpadText.length) {
        dialPadFilter = dialpadText;
    } else {
        dialPadFilter = nil;
    }
    
    [self loadData];
}

#pragma mark - Property Functions

- (void)setMissedFilter:(BOOL)amissedFilter {
    if (missedFilter == amissedFilter) {
        return;
    }
    missedFilter = amissedFilter;
    [self loadData];
}

#pragma mark - UITableViewDataSource Functions

- (void)loadData {
    [callLogs removeAllObjects];
    const MSList *logs = linphone_core_get_call_logs([LinphoneManager getLc]);
    while (logs != NULL) {
        LinphoneCallLog *log = (LinphoneCallLog *)logs->data;
        if (missedFilter) {
            if (linphone_call_log_get_status(log) == LinphoneCallMissed) {
                [callLogs addObject:[NSValue valueWithPointer:log]];
            }
        } else {
            if (dialPadFilter) {
                NSString *addr = [self addressFromCallLog:log];
                
                if (addr && [addr containsString:dialPadFilter]) {
                    [callLogs addObject:[NSValue valueWithPointer:log]];
                }
            } else {
                [callLogs addObject:[NSValue valueWithPointer:log]];
            }
        }
        
        logs = ms_list_next(logs);
    }
    
    [self.tableViewRecents reloadData];
}

- (IBAction)onSegmentCallType:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl*)sender;
    
    [self setMissedFilter:segmentedControl.selectedSegment];
    NSLog(@"segmentedControl.selectedSegment: %ld", (long)segmentedControl.selectedSegment);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return callLogs.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    HistoryTableCellView *cellView = [tableView makeViewWithIdentifier:@"CallLog" owner:self];
    
    LinphoneCallLog *log = [[callLogs objectAtIndex:row] pointerValue];
    [cellView setCallLog:log];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 55;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    //    selectedRow = marrayLoad[row];
    
    LinphoneCallLog *callLog = [[callLogs objectAtIndex:row] pointerValue];
    LinphoneAddress *addr;
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(callLog);
    } else {
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
    
    if (address != nil) {
        // Go to dialer view
        [[LinphoneManager instance] call:address displayName:address transfer:NO];
    }
    
    return YES;
}

- (NSString*) addressFromCallLog:(LinphoneCallLog*)callLog {
    LinphoneAddress *addr;
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(callLog);
    } else {
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
    
    if (address != nil) {
        return address;
    }
    
    return nil;
}

- (void) setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self.scrollViewRecents setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLinphoneCallUpdate object:nil];
}

@end
