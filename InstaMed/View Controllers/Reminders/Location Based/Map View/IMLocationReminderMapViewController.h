//
//  IMLocationReminderMapViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "IMUI.h"
#import "IMLocationMapPin.h"
#import "IMLocationController.h"

@protocol IMLocationReminderMapDelegate <NSObject>
@required
- (void)didSelectLocation:(CLLocation *)location withName:(NSString *)name;
@end

@interface IMLocationReminderMapViewController : IMBaseViewController <UISearchBarDelegate, MKMapViewDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) id<IMLocationReminderMapDelegate> delegate;

// Setup
- (id)initWithLocation:(CLLocation *)theLocation andName:(NSString *)theLocationName;

// Logic
- (void)performReverseGeolocationWithTerm:(NSString *)term;

@end
