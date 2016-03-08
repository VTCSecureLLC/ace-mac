//
//  AddContactDialogBox.m
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "AddContactDialogBox.h"
#import "LinphoneManager.h"
#import "Utils.h"
#import "CustomComboBox.h"
#import "ContactPictureManager.h"
#import <Quartz/Quartz.h>

@interface AddContactDialogBox () <CustomComboBoxDelegate>
{
    NSString *providerAddress;
    NSDictionary *providers;
    NSString *name;
    NSString *phone;
    NSString *nameField;
    NSString *numberField;
    NSString *customcomboboxField;
    NSImage *selectedImage;
}

@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *phoneTextField;
@property (weak) IBOutlet NSButton *doneButton;
@property (weak) IBOutlet NSImageView *contactImageView;
@property (strong, nonatomic) IBOutlet CustomComboBox *customComboBox;
@property (weak) IBOutlet NSButton* favoritesCheckBox;

@end

@implementation AddContactDialogBox

#pragma mark - Controller lifecycle

-(id) init
{
    self = [super initWithNibName:@"AddContactViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCustomComboBox];
    if (self.isEditing) {
        [self initContactPicture];
        [self setTitle:@"Edit contact"];
        [self.nameTextField setStringValue:self.oldName];
        [self.phoneTextField setStringValue:[Utils makeAccountNumberFromSipURI:self.oldPhone]];
        name = [self.nameTextField stringValue];
        phone = [self.phoneTextField stringValue];
        [self setNumberTextField];
    } else {
        [self setTitle:@"Add contact"];
    }
    [self fixInitialState];
}

- (void)initCustomComboBox {
    _customComboBox.delegate = self;
    _customComboBox.dataSource = [[Utils cdnResources] mutableCopy];
    [_customComboBox addEmptyProviderInDataSource];
    if (self.isEditing) {
        [_customComboBox selectItemByDomain:self.oldProviderName];
        providerAddress = self.oldProviderName;
    } else {
        [_customComboBox selectItemAtIndex:0];
        NSDictionary *dict = [[Utils cdnResources] objectAtIndex:[_customComboBox indexOfSelectedItem]];
        providerAddress = [dict objectForKey:@"domain"];
    }
}

- (void)initContactPicture {
    
    if ([self.oldName isEqualToString:@""]) {
        selectedImage = nil;
    } else {
        selectedImage = [[NSImage alloc]initWithContentsOfFile:[[ContactPictureManager sharedInstance] imagePathByName:self.oldName andSipURI:self.oldPhone]];
    }
    if (selectedImage) {
        [_contactImageView setWantsLayer: YES];
        _contactImageView.layer.borderWidth = 1.0;
        _contactImageView.layer.cornerRadius = _contactImageView.frame.size.height / 2 ;
        _contactImageView.layer.masksToBounds = YES;
        [self.contactImageView setImage:selectedImage];
    } else {
        [self.contactImageView setImage:[NSImage imageNamed:@"male"]];
    }
}

- (void)setNumberTextField {
     NSDictionary *dict = [_customComboBox.dataSource objectAtIndex:[_customComboBox indexOfSelectedItem]];
     if ([[dict objectForKey:@"domain"] isEqualToString:@"No Provider"]) {
         NSArray *tmpPhone = [self.oldPhone componentsSeparatedByString:@"sip:"];
         [self.phoneTextField setStringValue:[tmpPhone lastObject]];
     } else {
         [self.phoneTextField setStringValue:[Utils makeAccountNumberFromSipURI:self.oldPhone]];
     }
}

- (void)fixInitialState {
    nameField = [self.nameTextField stringValue];
    numberField = [self.phoneTextField stringValue];
    customcomboboxField = providerAddress;
    // VATRP-2376: we will need to specify if this is a favorite or not here
    bool isFavorite = false;
    if (isFavorite)
    {
        [_favoritesCheckBox setState:NSOnState];
    }
    else
    {
        [_favoritesCheckBox setState:NSOffState];
    }
        
}

- (BOOL)isChangedFields {
    NSDictionary *dict = [_customComboBox.dataSource objectAtIndex:[_customComboBox indexOfSelectedItem]];
    if ([nameField isEqualToString:[self.nameTextField stringValue]] &&
        [numberField isEqualToString:[self.phoneTextField stringValue]] &&
        [customcomboboxField isEqualToString:[dict objectForKey:@"domain"]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Buttons action functions

- (IBAction)onButtonDone:(id)sender {
    [[ContactPictureManager sharedInstance] saveImage:selectedImage withName:[self.nameTextField stringValue]
                                            andSipURI:[self createFullSipUriFromString:[self.phoneTextField stringValue]]];
    if (self.isEditing) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoEditDone"
                                                            object:@{@"name" : [self.nameTextField stringValue],
                                                                     @"phone": [self createFullSipUriFromString:[self.phoneTextField stringValue]],
                                                                     @"oldName": self.oldName,
                                                                     @"oldPhone" : self.oldPhone,
                                                                     @"provider" : providerAddress}
                                                          userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoFilled"
                                                            object:@{@"name" : [self.nameTextField stringValue],
                                                                     @"phone": [self createFullSipUriFromString:[self.phoneTextField stringValue]],
                                                                     @"provider" : providerAddress}
                                                          userInfo:nil];
    }
    [self dismissController:nil];
}

#pragma mark - helper functions

- (void)makeProviderName {
    LinphoneProxyConfig* current_conf = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &current_conf);
    if( current_conf != NULL ){
        const char *domain = linphone_proxy_config_get_domain(current_conf);
        providerAddress = [NSString stringWithUTF8String:domain];
    }
}

- (NSString*)createFullSipUriFromString:(NSString*)str {
    NSString *sipUri = str;
    if ([Utils nsStringIsValidSip:sipUri]) {
        sipUri = [@"sip:" stringByAppendingString:sipUri];
    } else {
        if ([providerAddress isEqualToString:@"No Provider"]) {
            NSDictionary *dict = [[Utils cdnResources] objectAtIndex:0];
            providerAddress = [dict objectForKey:@"domain"];
            sipUri = [Utils makeSipURIWithAccountName:str andProviderAddress:providerAddress];
        } else {
            sipUri = [Utils makeSipURIWithAccountName:str andProviderAddress:providerAddress];
        }
    }
    
    return sipUri;
}

- (BOOL)isDoneEditions {
    
    if (![name isEqualToString:[self.nameTextField stringValue]] || ![phone isEqualToString:[self.phoneTextField stringValue]]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - CustomComboBox delegate methods

- (void)customComboBox:(CustomComboBox *)sender didSelectedItem:(NSDictionary *)selectedItem {
    providerAddress = [selectedItem objectForKey:@"domain"];
}

- (void)customComboBox:(CustomComboBox *)sender didOpenedComboTable:(BOOL)isOpened {
    [_doneButton setEnabled:!isOpened];
}

#pragma mark - Chaning profile picture methods

- (IBAction)onButtonChangePicture:(id)sender {
    
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    
    [pictureTaker setValue:[NSNumber numberWithBool:YES]
                    forKey:IKPictureTakerShowEffectsKey];
    
    [pictureTaker popUpRecentsMenuForView:self.contactImageView
                             withDelegate:self
                           didEndSelector:@selector(pictureTakerDidEnd:code:contextInfo:)
                              contextInfo:nil];

}

- (void)pictureTakerDidEnd:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf
{
    if(returnCode == NSOKButton) {
        NSImage *outputImage = [pictureTaker outputImage];
        selectedImage = outputImage;
        if (selectedImage) {
            [_contactImageView setWantsLayer: YES];
            _contactImageView.layer.borderWidth = 1.0;
            _contactImageView.layer.cornerRadius = _contactImageView.frame.size.height / 2 ;
            _contactImageView.layer.masksToBounds = YES;
            [self.contactImageView setImage:selectedImage];
        } else {
            [self.contactImageView setImage:[NSImage imageNamed:@"male"]];
        }
    }
    else{
        // The user canceled, so there is nothing to do.
    }
}

@end
