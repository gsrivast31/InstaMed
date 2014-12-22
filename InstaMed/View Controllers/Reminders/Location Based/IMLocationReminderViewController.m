//
//  IMLocationReminderViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAppDelegate.h"
#import "IMLocationReminderViewController.h"
#import "IMLocationController.h"

@interface IMLocationReminderViewController ()
{
    NSString *message;
    NSInteger trigger;
    
    BOOL currentlyDeterminingUserLocation;
    CLLocation *location;
    NSString *locationName;
}

@end

@implementation IMLocationReminderViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Add Reminder", nil);

        message = @"";
        trigger = 0;
        location = nil;
        
        currentlyDeterminingUserLocation = NO;
    }
    return self;
}
- (id)initWithReminder:(IMReminder *)theReminder
{
    self = [self init];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit reminder", nil);
        self.reminder = theReminder;

        IMReminder *reminder = (IMReminder *)[self reminder];
        if(reminder)
        {
            message = reminder.message;
            trigger = [reminder.trigger integerValue];
            location = [[CLLocation alloc] initWithLatitude:[reminder.latitude doubleValue] longitude:[reminder.longitude doubleValue]];
            locationName = reminder.locationName;
        }
        
        currentlyDeterminingUserLocation = NO;
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![self reminder])
    {
        [self.tableView reloadData];
        
        IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.accessoryControl becomeFirstResponder];
    }
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addReminder:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
}

#pragma mark - Logic
- (void)addReminder:(id)sender
{
    [self.view endEditing:YES];
    
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc)
    {
        if(message && [message length] && location && locationName)
        {
            NSError *error = nil;
            
            IMReminder *newReminder = [self reminder];
            if(!newReminder)
            {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMReminder" inManagedObjectContext:moc];
                newReminder = (IMReminder *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                newReminder.type = [NSNumber numberWithInteger:kReminderTypeLocation];            
                newReminder.created = [NSDate date];
            }
            newReminder.message = message;
            newReminder.locationName = locationName;        
            newReminder.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
            newReminder.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
            newReminder.trigger = [NSNumber numberWithInteger:trigger];
            [moc save:&error];
            
            if(error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"We were unable to save your reminder for the following reason: %@", nil), [error localizedDescription]]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            else
            {
                // Setup region monitoring
                [[IMLocationController sharedInstance] setupLocationMonitoringForApplicableReminders];
                
                // Notify anyone interested that we've updated our reminders
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                
                [self handleBack:self withSound:NO];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:NSLocalizedString(@"Please complete all required fields", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}
- (void)geolocateUser
{
    currentlyDeterminingUserLocation = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    [[IMLocationController sharedInstance] fetchUserLocationWithSuccess:^(CLLocation *theLocation) {
        location = theLocation;
        
        [[[IMLocationController sharedInstance] geocoder] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if(!error)
            {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                locationName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            }
            else
            {
                locationName = nil;
            }
            
            currentlyDeterminingUserLocation = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }];
    } failure:^(NSError *error) {
        currentlyDeterminingUserLocation = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMReminderCell"];
    if (cell == nil)
    {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMReminderCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.font = [IMFont standardRegularFontWithSize:16.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:114.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Alert", nil);
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            textField.delegate = self;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.text = message;
            textField.placeholder = NSLocalizedString(@"Your reminder message", nil);
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.adjustsFontSizeToFitWidth = NO;
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.textAlignment = NSTextAlignmentRight;
            textField.font = [IMFont standardMediumFontWithSize:16.0f];
            textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.accessoryView = textField;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Location", nil);
            
            if(currentlyDeterminingUserLocation)
            {
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityIndicator startAnimating];
                cell.accessoryView = activityIndicator;
            }
            else
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
                label.backgroundColor = [UIColor clearColor];
                label.text = location ? locationName : NSLocalizedString(@"No location", nil);
                label.textAlignment = NSTextAlignmentRight;
                label.font = [IMFont standardMediumFontWithSize:16.0f];
                label.textColor = location ? [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] : [UIColor lightGrayColor];
                cell.accessoryView = label;
            }
        }
    }
    else
    {

        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"On Arrival", @"On arrival to a geographic location");
            cell.accessoryType = (trigger == 0) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"On Departure", @"On departure from a geographic location");
            cell.accessoryType = (trigger == 1) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Both", nil);
            cell.accessoryType = (trigger == 2) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Reminder details", nil);
    }
    else
    {
        return NSLocalizedString(@"When you'd like to be reminded", nil);
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    IMGenericTableHeaderView *header = [[IMGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}

#pragma mark - UITableViewDelegate reference
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 1)
        {
            [self.view endEditing:YES];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Current Location", @"Current geographic location"), NSLocalizedString(@"Search", nil), nil];
            [sheet showInView:self.view];
        }
    }
    else if(indexPath.section == 1)
    {
        trigger = indexPath.row;
        [aTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UILocationReminderMapDelegate methods
- (void)didSelectLocation:(CLLocation *)theLocation withName:(NSString *)theLocationName
{
    location = theLocation;
    locationName = theLocationName;
    
    [self.tableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        message = textField.text;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self geolocateUser];
    }
    else if(buttonIndex == 1)
    {
        IMLocationReminderMapViewController *vc = nil;
        if(location && locationName)
        {
            vc = [[IMLocationReminderMapViewController alloc] initWithLocation:location andName:locationName];
        }
        else
        {
            vc = [[IMLocationReminderMapViewController alloc] init];
        }
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
