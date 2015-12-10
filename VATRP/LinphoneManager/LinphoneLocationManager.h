
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LinphoneLocationManager : NSObject <CLLocationManagerDelegate>

@property CLAuthorizationStatus authorizationStatus;

- (NSString*)currentLocationAsText;
- (void)startMonitoring;
+(LinphoneLocationManager *)sharedManager;
-(BOOL)locationPlausible;

@end
