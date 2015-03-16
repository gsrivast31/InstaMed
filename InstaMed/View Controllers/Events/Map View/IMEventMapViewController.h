//
//  IMEventMapViewController.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 06/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "IMBaseViewController.h"
#import "IMEventMapPin.h"

@interface IMEventMapViewController : IMBaseViewController

// Setup
- (id)initWithLocation:(CLLocation *)theLocation;

// Logic
- (void)positionPin:(CLLocation *)aLocation;

@end
