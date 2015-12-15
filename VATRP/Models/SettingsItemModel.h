//
//  SettingsItemModel.h
//  ACE
//
//  Created by Norayr Harutyunyan on 12/8/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    controllerType_checkbox,
    controllerType_textfield,
    controllerType_color,
} controllerType;

@interface SettingsItemModel : NSObject

- (id) initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, assign) controllerType controller_Type;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *defaultValue;
@property (nonatomic, retain) NSString *userDefaultsKey;

@end
