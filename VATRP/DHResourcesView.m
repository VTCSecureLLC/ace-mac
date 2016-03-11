//
//  DHResourcesView.m
//  ACE
//
//  Created by User on 05/01/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "DHResourcesView.h"
#import "LinphoneManager.h"
#import "CallService.h"

@interface DHResourcesView () {
    
}

@property (weak) IBOutlet NSScrollView *scrollViewItems;
@property (weak) IBOutlet NSTableView *tableView;

@end


@implementation DHResourcesView {
    NSMutableArray *cdnResources;
    NSURLRequest *cdnRequest;
    NSURLSession *urlSession;
    NSString *cdnDatabase;
}

-(id) init
{
    self = [super initWithNibName:@"DHResourcesView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void) awakeFromNib {
    [super awakeFromNib];
    cdnDatabase = @"http://cdn.vatrp.net/numbers.json";
    [self loadDataFromCDN];
}


- (void) setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self.scrollViewItems setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
}

-(void) loadDataFromCDN{
    cdnResources = [[NSMutableArray alloc] init];
    urlSession = [NSURLSession sharedSession];
    
    [[urlSession dataTaskWithURL:[NSURL URLWithString:(NSString*)cdnDatabase] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonParsingError = nil;
        if(data){
            NSArray *resources = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0 error:&jsonParsingError];
            NSDictionary *resource;
            for(int i=0; i < [resources count];i++){
                resource= [resources objectAtIndex:i];
                [cdnResources addObject:resource];
                NSLog(@"Loaded CDN Resource: %@", [resource objectForKey:@"name"]);
            }
            [self.tableView reloadData];
        }
        
    }] resume];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [cdnResources count];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSDictionary *resource = [cdnResources objectAtIndex:[[notification object] selectedRow]];
    //NSString *name = [resource objectForKey:@"name"];
    NSString *address = [resource objectForKey:@"address"];
    
    [CallService callTo:address];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    [textField setEditable:NO];
    [textField setBordered:NO];
    [textField sizeToFit];
    NSDictionary *resource= [cdnResources objectAtIndex:row];
    
    NSString *name = [resource objectForKey:@"name"];
    textField.stringValue = [NSString stringWithFormat:@"%@", name];
    return textField;
    
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30;
}


@end
