//
//  IMAppDelegate.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "REFrostedViewController.h"

#import "IMUI.h"

@class IMUser;

@interface IMAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) IMUser *currentUser;

// Setup
+ (IMAppDelegate *)sharedAppDelegate;

// Logic
- (void)setupStyling;
- (void)setupDefaultConfigurationValues;

@end

