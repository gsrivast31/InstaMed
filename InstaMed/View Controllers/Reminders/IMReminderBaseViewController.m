//
//  IMReminderBaseViewController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 13/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReminderBaseViewController.h"

@interface IMReminderBaseViewController ()

@end

@implementation IMReminderBaseViewController
@synthesize reminderOID = _reminderOID;

#pragma mark - Setup
- (id)initWithReminder:(IMReminder *)theReminder
{
    self = [super init];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit reminder", nil);
        
        self.reminder = theReminder;
    }
    
    return self;
}

#pragma mark - Logic
- (void)reloadViewData:(NSNotification *)note
{
    [super reloadViewData:note];
    
    NSDictionary *userInfo = [note userInfo];
    if(userInfo && userInfo[NSDeletedObjectsKey])
    {
        for(NSManagedObjectID *objectID in userInfo[NSDeletedObjectsKey])
        {
            if(self.reminderOID && [objectID isEqual:self.reminderOID])
            {
                [self handleBack:self withSound:NO];
                return;
            }
        }
    }
}

#pragma mark - Accessors
- (IMReminder *)reminder
{
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(!moc) return nil;
    if(!self.reminderOID) return nil;
    
    NSError *error = nil;
    IMReminder *reminder = (IMReminder *)[moc existingObjectWithID:self.reminderOID error:&error];
    if (!reminder)
    {
        self.reminderOID = nil;
    }
    
    return reminder;
}
- (void)setReminder:(IMReminder *)theReminder
{
    NSError *error = nil;
    if(theReminder.objectID.isTemporaryID && ![theReminder.managedObjectContext obtainPermanentIDsForObjects:@[theReminder] error:&error])
    {
        self.reminderOID = nil;
    }
    else
    {
        self.reminderOID = theReminder.objectID;
    }
}
- (IMReminderRule *)reminderRule
{
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(!moc) return nil;
    if(!self.reminderRuleOID) return nil;
    
    NSError *error = nil;
    IMReminderRule *reminderRule = (IMReminderRule *)[moc existingObjectWithID:self.reminderRuleOID error:&error];
    if (!reminderRule)
    {
        self.reminderRuleOID = nil;
    }
    
    return reminderRule;
}
- (void)setReminderRule:(IMReminderRule *)theReminderRule
{
    NSError *error = nil;
    if(theReminderRule.objectID.isTemporaryID && ![theReminderRule.managedObjectContext obtainPermanentIDsForObjects:@[theReminderRule] error:&error])
    {
        self.reminderRuleOID = nil;
    }
    else
    {
        self.reminderRuleOID = theReminderRule.objectID;
    }
}
@end
