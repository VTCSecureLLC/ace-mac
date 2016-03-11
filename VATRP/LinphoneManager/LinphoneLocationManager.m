//
//  LinphoneLocationManager.m
//
//  Created by Christophe Deschamps on June 9th 2014
//

#import "LinphoneLocationManager.h"
#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"


@interface LinphoneLocationManager()

@property(nonatomic,strong)CLLocationManager* locationManager;

@end


@implementation LinphoneLocationManager

- (id)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startMonitoring{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (NSString*)currentLocationAsText{
    return [NSString stringWithFormat:@"<geo:%f,%f>",self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude ];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
            NSLog(@"Location Services are now Authorised");
            [_locationManager startUpdatingLocation];
            
            break;
            
        case kCLAuthorizationStatusDenied: {
            NSLog(@"Location Services are now Denied");
            self.authorizationStatus = kCLAuthorizationStatusDenied;
        }
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Location Services are now Not Determined");
            
            //  We need to triger the OS to ask the user for permission.
            [_locationManager startUpdatingLocation];
            [_locationManager stopUpdatingLocation];
            
            break;
            
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location Services are now Restricted");
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) {
        NSLog(@"locationManager didFailWithError: kCLErrorDenied");
    }
}

-(BOOL)locationPlausible {
    return self.locationManager != nil && self.locationManager.location != nil && self.locationManager.location.coordinate.latitude != 0 && self.locationManager.location.coordinate.longitude != 0;
}

#pragma mark -
#pragma mark Singleton instance

+(LinphoneLocationManager *)sharedManager {
    static dispatch_once_t pred;
    static LinphoneLocationManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[LinphoneLocationManager alloc] init];
    });
    return shared;
}

@end

