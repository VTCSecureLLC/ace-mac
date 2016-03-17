//
//  RecentsViewController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/28/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "RecentsViewController.h"
#import "HistoryTableCellView.h"
#import "LinphoneManager.h"
#import "CallService.h"

@interface RecentsViewController () {
    NSMutableArray *callLogs;
    BOOL missedFilter;
}

@property (weak) IBOutlet NSTableView *tableViewCallLog;
@property (weak) IBOutlet NSSegmentedControl *segmentedControlCallType;

- (void)loadData;

@end

@implementation RecentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    callLogs = [[NSMutableArray alloc] init];
    missedFilter = false;
}

#pragma mark - ViewController Functions

- (void) viewWillAppear {
    [super viewWillAppear];
    
    self.segmentedControlCallType.selectedSegment = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdate:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
    [self loadData];
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLinphoneCallUpdate object:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Event Functions

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
            [callLogs addObject:[NSValue valueWithPointer:log]];
        }
        logs = ms_list_next(logs);
    }

    [self.tableViewCallLog reloadData];
}

- (IBAction)onSegmentCallType:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl*)sender;

    [self setMissedFilter:segmentedControl.selectedSegment];
    NSLog(@"segmentedControl.selectedSegment: %ld", (long)segmentedControl.selectedSegment);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return callLogs.count;
}

#if defined __MAC_10_9 || defined __MAC_10_8
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
#else
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
#endif
    HistoryTableCellView *cellView = [tableView makeViewWithIdentifier:@"CallLog" owner:self];
    
    LinphoneCallLog *log = [[callLogs objectAtIndex:row] pointerValue];
    [cellView setCallLog:log];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40;
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
        [CallService callTo:address];
    }

    return YES;
}

@end
