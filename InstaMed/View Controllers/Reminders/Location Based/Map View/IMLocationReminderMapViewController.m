//
//  IMLocationReminderMapViewController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 04/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMLocationReminderMapViewController.h"
#import "MBProgressHUD.h"

@interface IMLocationReminderMapViewController ()
{
    IBOutlet MKMapView *mapView;
    
    UISearchBar *searchBar;
    CLLocation *location;
    NSString *locationName;
    
    UIBarButtonItem *leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem;
    
    UISearchDisplayController *searchDisplayController;
    IMLocationMapPin *pin;
    NSMutableArray *results;
}
@end

@implementation IMLocationReminderMapViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNibName:@"IMLocationReminderMapView" bundle:nil];
    if (self) {
        location = nil;
        locationName = nil;
        
        self.title = NSLocalizedString(@"Reminder Location", @"Title for screen showing the geographic location of a geo-fenced reminder");
        
        pin = [[IMLocationMapPin alloc] init];
        results = [NSMutableArray array];
    }
    
    return self;
}
- (id)initWithLocation:(CLLocation *)theLocation andName:(NSString *)theLocationName;
{
    self = [self init];
    if (self) {
        location = theLocation;
        locationName = theLocationName;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add our search bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    [searchBar sizeToFit];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveLocation:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
    
    if(location)
    {
        [self positionPin:location];
    }
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    searchBar.frame = CGRectMake(0, self.topLayoutGuide.length, self.view.frame.size.width, 44.0f);
}

#pragma mark - Logic
- (void)positionPin:(CLLocation *)aLocation;
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
- (void)performReverseGeolocationWithTerm:(NSString *)term
{
    if(!term || ![term length]) return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[IMLocationController sharedInstance] geocoder] geocodeAddressString:term completionHandler:^(NSArray *placemarks, NSError *error) {
        results = [NSMutableArray arrayWithArray:placemarks];
        [[searchDisplayController searchResultsTableView] reloadData];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

#pragma mark - UI
- (void)saveLocation:(id)sender
{
    if(location && locationName)
    {
        [self.delegate didSelectLocation:location withName:locationName];
        
        [self handleBack:self withSound:NO];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"Please select a valid location before continuing", @"Error message shown to users when setting up a geographical reminder")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [results count];
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMReminderCell"];
    if (cell == nil)
    {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMReminderCell"];
    }
    
    CLPlacemark *aPlacemark = [results objectAtIndex:indexPath.row];
    if(aPlacemark)
    {
        cell.textLabel.text = [[aPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CLPlacemark *placemark = [results objectAtIndex:indexPath.row];
    if(placemark)
    {
        location = placemark.location;
        locationName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        [self positionPin:placemark.location];
        
        [searchDisplayController setActive:NO animated:YES];
    }
}

#pragma mark - UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [self performReverseGeolocationWithTerm:aSearchBar.text];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(performReverseGeolocationWithTerm:) withObject:searchText afterDelay:0.5];
}

@end
