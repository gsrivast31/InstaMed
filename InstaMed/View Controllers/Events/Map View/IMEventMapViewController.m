//
//  IMEventMapViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEventMapViewController.h"

@interface IMEventMapViewController ()
{
    MKMapView *mapView;
    IMEventMapPin *pin;
    
    CLLocation *location;
}
@end

@implementation IMEventMapViewController

#pragma mark - Setup
- (id)initWithLocation:(CLLocation *)theLocation
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        self.title = NSLocalizedString(@"Event Location", @"Geo-location of event");
        location = theLocation;
        pin = [[IMEventMapPin alloc] init];
    }
    
    return self;
}
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    mapView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:mapView];
    
    self.view = view;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mapView.frame = self.view.frame;
    [self positionPin:location];
    
    UIColor *tintColor = kDefaultTintColor;
    [self.navigationController.navigationBar setTintColor:tintColor];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[IMFont standardDemiBoldFontWithSize:17.0f]}];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    mapView.frame = self.view.bounds;
}

#pragma mark - Logic
- (void)positionPin:(CLLocation *)aLocation
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = aLocation.coordinate.latitude;
    newRegion.center.longitude = aLocation.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.005;
    newRegion.span.longitudeDelta = 0.005;
    
    pin.coordinate = aLocation.coordinate;
    [mapView setRegion:newRegion animated:YES];
    [mapView addAnnotation:pin];
}

@end
