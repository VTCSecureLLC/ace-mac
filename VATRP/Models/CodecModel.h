//
//  CodecModel.h
//  ACE
//
//  Created by Ruben Semerjyan on 9/28/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodecModel : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *preference;
@property (nonatomic, assign) int rate;
@property (nonatomic, assign) int channels;
@property (nonatomic, assign) BOOL status;

- (id) initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) serializedDictionary;

@end
