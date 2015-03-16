//
//  IMEventLocationMapView.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 03/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "IMEventLocationMapView.h"
#import "IMEventMapPin.h"

@interface IMEventLocationMapView ()
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation IMEventLocationMapView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
        
        _mapView = [[MKMapView alloc] initWithFrame:self.bounds];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mapView.zoomEnabled = NO;
        _mapView.pitchEnabled = NO;
        _mapView.scrollEnabled = NO;
        [self addSubview:_mapView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mapView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
}

#pragma mark - Logic
- (void)setLocation:(CLLocationCoordinate2D)coordinate
{
    IMEventMapPin *pin = [[IMEventMapPin alloc] init];
    pin.coordinate = coordinate;
    
    [_mapView addAnnotation:pin];
    [_mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.01))];
}

@end
