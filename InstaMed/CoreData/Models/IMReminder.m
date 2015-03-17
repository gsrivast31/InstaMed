//
//  IMReminder.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReminder.h"
#import "IMReminderController.h"

@implementation IMReminder

@dynamic active;
@dynamic created;
@dynamic date;
@dynamic days;
@dynamic latitude;
@dynamic locationName;
@dynamic longitude;
@dynamic message;
@dynamic trigger;
@dynamic type;

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    
    [[IMReminderController sharedInstance] deleteNotificationsWithID:self.guid];
}

@end
