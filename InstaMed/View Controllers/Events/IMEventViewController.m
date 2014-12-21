//
//  IMEventViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMEventViewController.h"
#import "IMReminderController.h"
#import "IMLocationController.h"

#import "IMBGEventRepresentation.h"
#import "IMNoteEventRepresentation.h"
#import "IMMealEventRepresentation.h"

#import "IMReading.h"
#import "IMNote.h"
#import "IMMeal.h"

@interface IMEventViewController ()
@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

// Metadata logic
- (void)requestCurrentLocation;
@end

@implementation IMEventViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNibName:@"IMEventView" bundle:nil];
    if(self)
    {
        self.title = NSLocalizedString(@"Add Entry", nil);
        
        IMBGEventRepresentation *eventRepresentation = [[IMBGEventRepresentation alloc] init];
        eventRepresentation.delegate = self;
        eventRepresentation.dataSource = self;
        
        IMNoteEventRepresentation *eventRepresentationNote = [[IMNoteEventRepresentation alloc] init];
        eventRepresentationNote.delegate = self;
        eventRepresentationNote.dataSource = self;
        
        IMMealEventRepresentation *eventRepresentationMeal = [[IMMealEventRepresentation alloc] init];
        eventRepresentationMeal.delegate = self;
        eventRepresentationMeal.dataSource = self;
        
        self.events = [NSMutableArray array];
        [self.events addObject:eventRepresentation];
        [self.events addObject:eventRepresentationNote];
        [self.events addObject:eventRepresentationMeal];
        
        [self commonInit];
    }
    
    return self;
}
- (id)initWithEvent:(IMEvent *)event
{
    self = [self init];
    if(self)
    {
        IMEventRepresentation *eventRepresentation = nil;
        if([event isKindOfClass:[IMReading class]])
        {
            eventRepresentation = [[IMBGEventRepresentation alloc] initWithEvent:event];
        }
        else if([event isKindOfClass:[IMNote class]])
        {
            eventRepresentation = [[IMNoteEventRepresentation alloc] initWithEvent:event];
        }
        else if([event isKindOfClass:[IMMeal class]])
        {
            eventRepresentation = [[IMMealEventRepresentation alloc] initWithEvent:event];
        }
        
        if(eventRepresentation)
        {
            eventRepresentation.delegate = self;
            eventRepresentation.dataSource = self;
            
            self.events = [NSMutableArray array];
            [self.events addObject:eventRepresentation];
        }
        
        [self commonInit];
    }
    
    return self;
}
- (void)commonInit
{
    /*
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    */
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(saveEvents)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
    
    // If we've been asked to automatically geotag events, kick that off here
    if([[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallyGeotagEvents])
    {
        [self requestCurrentLocation];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IMEventSectionHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"IMEventSectionHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"IMNewEventInputViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"IMEventInputViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"IMNewEventTextBlockViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"IMEventTextBlockViewCell"];
}

#pragma mark - Logic
- (void)saveEvents
{
    [self.view endEditing:YES];
    
    NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSError *error = nil;
        for(IMEventRepresentation *eventRepresentation in self.events)
        {
            error = [eventRepresentation validationError];
            if(error)
            {
                break;
            }
        }
        
        if(error)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
        else
        {
            NSMutableArray *newEvents = [NSMutableArray array];
            for(IMEventRepresentation *eventRepresentation in self.events)
            {
                NSError *error = nil;
                IMEvent *event = nil;
                [eventRepresentation saveEvent:&event error:&error];
                
                if(!error)
                {
                    // Don't set reminders for pre-existing events
                    if(!eventRepresentation.event)
                    {
                        [newEvents addObject:event];
                    }
                }
            }
            
            // Iterate over our newly created events and see if any match our rules
            NSArray *rules = [[IMReminderController sharedInstance] fetchAllReminderRules];
            if(rules && [rules count])
            {
                for(IMReminderRule *rule in rules)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:rule.predicate];
                    if(predicate)
                    {
                        NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:[newEvents filteredArrayUsingPredicate:predicate]];
                        
                        // If we have a match go ahead and create a reminder
                        if(filteredEvents && [filteredEvents count])
                        {
                            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMReminder" inManagedObjectContext:moc];
                            IMReminder *newReminder = (IMReminder *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                            newReminder.created = [NSDate date];
                            
                            NSDate *triggerDate = [[filteredEvents objectAtIndex:0] valueForKey:@"timestamp"];
                            
                            newReminder.message = rule.name;
                            if([rule.intervalType integerValue] == kMinuteIntervalType)
                            {
                                newReminder.date = [triggerDate dateByAddingMinutes:[rule.intervalAmount integerValue]];
                            }
                            else if([rule.intervalType integerValue] == kHourIntervalType)
                            {
                                newReminder.date = [triggerDate dateByAddingHours:[rule.intervalAmount integerValue]];
                            }
                            else if([rule.intervalType integerValue] == kDayIntervalType)
                            {
                                newReminder.date = [triggerDate dateByAddingDays:[rule.intervalAmount integerValue]];
                            }
                            newReminder.type = [NSNumber numberWithInteger:kReminderTypeDate];
                            
                            NSError *error = nil;
                            [moc save:&error];
                            
                            if(!error)
                            {
                                [[IMReminderController sharedInstance] setNotificationsForReminder:newReminder];
                                
                                // Notify anyone interested that we've updated our reminders
                                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                            }
                        }
                    }
                }
            }

            [self handleBack:self withSound:NO];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"We're unable to save your data as a sync is in progress!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Metadata logic
- (void)requestCurrentLocation
{
    [[IMLocationController sharedInstance] fetchUserLocationWithSuccess:^(CLLocation *location) {
        NSLog(@"got loc: %@", location);
    } failure:^(NSError *error) {
        NSLog(@"current loc: %@", error);
    }];
}

#pragma mark - IMEventRepresentationDelegate methods
- (void)eventRepresentation:(IMEventRepresentation *)representation willSaveEvent:(IMEvent *)event
{
    event.timestamp = [NSDate date];
    
    // Generate tags based on this events notes
    NSArray *tags = [[IMTagController sharedInstance] fetchTagsInString:event.notes];
    [[IMTagController sharedInstance] assignTags:tags toEvent:event];
}

#pragma mark - IMEventRepresentationDataSource methods
- (UITableView *)tableViewForEventRepresentation:(IMEventRepresentation *)representation
{
    return self.tableView;
}

#pragma mark - IMEventSectionHeaderViewDelegate methods
- (void)headerDeleteButtonPressedForEventRepresentation:(IMEventRepresentation *)eventRepresentation
{
    NSUInteger section = [self.events indexOfObject:eventRepresentation];
    if(section != NSNotFound)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Entry", nil)
                                                            message:NSLocalizedString(@"Are you sure you'd like to permanently delete this entry?", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        alertView.tag = section;
        alertView.delegate = self;
        [alertView show];
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1+[self.events count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section <= [self.events count]-1)
    {
        IMEventRepresentation *eventRepresentation = self.events[section];
        return [eventRepresentation numberOfFields];
    }
    else
    {
        return 1;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section <= [self.events count]-1)
    {
        IMEventRepresentation *eventRepresentation = self.events[section];
        return [eventRepresentation title];
    }
    else
    {
        return NSLocalizedString(@"Extra information", @"Extra information relating to a journal entry");
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section <= [self.events count]-1)
    {
        IMEventRepresentation *eventRepresentation = self.events[indexPath.section];
        return [eventRepresentation cellForTableView:tableView withFieldIndex:indexPath.row];
    }
    else
    {
        return [tableView dequeueReusableCellWithIdentifier:@"IMEventInputViewCell"];
    }
    
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section <= [self.events count]-1)
    {
        IMEventSectionHeaderView *headerView = (IMEventSectionHeaderView *)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"IMEventSectionHeaderView"];
        headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        headerView.eventRepresentation = self.events[section];
        headerView.delegate = self;
        
        return (UIView *)headerView;
    }
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section <= [self.events count]-1)
    {
        IMEventRepresentation *eventRepresentation = self.events[indexPath.section];
        return [eventRepresentation heightForCellWithFieldIndex:indexPath.row inTableView:tableView];
    }
    else
    {
        return 44.0f;
    }
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSUInteger section = alertView.tag;
        
        IMEventRepresentation *eventRepresentation = self.events[section];
        if(eventRepresentation)
        {
            NSError *error = nil;
            BOOL deleted = [eventRepresentation deleteEvent:&error];
            
            if(deleted)
            {
                if([self.events count] == 1)
                {
                    [self handleBack:self withSound:NO];
                }
                else
                {
                    [self.events removeObjectAtIndex:section];
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"There was an error while trying to delete this event: %@", nil), [error localizedDescription]]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

@end
