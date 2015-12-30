//
//  ResourcesViewController.m
//  ACE
//
//  Created by Zack Matthews on 12/21/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ResourcesViewController.h"
#import "LinphoneManager.h"
#import "CallService.h"

@interface ResourcesViewController ()

@end

@implementation ResourcesViewController{
    NSMutableArray *cdnResources;
    NSURLRequest *cdnRequest;
    NSURLSession *urlSession;
    
}

@synthesize tableView;

const NSString *cdnDatabase = @"http://cdn.vatrp.net/numbers.json";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDataFromCDN];
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
            [tableView reloadData];
        }
        
    }] resume];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [cdnResources count];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSDictionary *resource = [cdnResources objectAtIndex:[[notification object] selectedRow]];
    NSString *name = [resource objectForKey:@"name"];
    NSString *address = [resource objectForKey:@"address"];
    
    [CallService callTo:address];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.tableView.frame.size.height)];
    [textField setEditable:NO];
    [textField setBordered:NO];
    [textField sizeToFit];
    NSDictionary *resource= [cdnResources objectAtIndex:row];
    
    NSString *name = [resource objectForKey:@"name"];
    textField.stringValue = [NSString stringWithFormat:@"%@", name];
    return textField;
    
}


@end
