//
//  CodecModel.h
//  ACE
//
//  Created by Edgar Sukiasyan on 9/28/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodecModel : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int rate;
@property (nonatomic, assign) int channels;
@property (nonatomic, assign) BOOL status;

@end
