//
//  CodecModel.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/28/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CodecModel.h"
#import "Utils.h"

@implementation CodecModel

@synthesize name;
@synthesize preference;
@synthesize rate;
@synthesize channels;
@synthesize status;

- (id) initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    
    if (self) {
        self.name = [Utils stringValueDict:dictionary Key:@"name"];
        self.rate = [Utils intValueDict:dictionary Key:@"rate"];
        self.channels = [Utils intValueDict:dictionary Key:@"channels"];
        self.status = [Utils intValueDict:dictionary Key:@"status"];
    }
    
    return self;
}

- (id) init {
    self = [super init];
    
    if (self) {
        self.name = @"G729";
        self.rate = 8000;
        self.channels = 2;
        self.status = YES;
    }
    
    return self;
}

- (NSDictionary*) serializedDictionary {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    [mDict setObject:self.name forKeyedSubscript:@"name"];
    [mDict setObject:[NSNumber numberWithInt:self.rate] forKeyedSubscript:@"rate"];
    [mDict setObject:[NSNumber numberWithInt:self.channels] forKeyedSubscript:@"channels"];
    [mDict setObject:[NSNumber numberWithBool:self.status] forKeyedSubscript:@"status"];
    
    return (NSDictionary*)mDict;
}

@end
