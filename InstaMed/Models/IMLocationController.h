//
//  IMLocationController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IMReminderController.h"

typedef void (^IMCurrentLocationSuccessCallback)(CLLocation*);
typedef void (^IMCurrentLocationFailureCallback)(NSError*);
typedef void (^IMReverseGeolocateSuccessCallback)(NSArray*);
typedef void (^IMReverseGeolocateFailureCallback)(NSError*);

@interface IMLocationController : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong) CLGeocoder *geocoder;

+ (id)sharedInstance;

// Logic
- (void)fetchUserLocationWithSuccess:(IMCurrentLocationSuccessCallback)successCallback
                             failure:(IMCurrentLocationFailureCallback)failureCallback;
- (void)reverseGeocodeLocation:(CLLocation *)location
                   withSuccess:(IMReverseGeolocateSuccessCallback)successCallback
                       failure:(IMReverseGeolocateFailureCallback)failureCallback;
- (void)setupLocationMonitoringForApplicableReminders;

@end
