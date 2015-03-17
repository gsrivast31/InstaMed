//
//  IMReminderBaseViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 13/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMBaseViewController.h"
#import "IMReminder.h"
#import "IMReminderRule.h"

@interface IMReminderBaseViewController : IMBaseTableViewController
@property (nonatomic, strong) IMReminder *reminder;
@property (nonatomic, strong) NSManagedObjectID *reminderOID;
@property (nonatomic, strong) IMReminderRule *reminderRule;
@property (nonatomic, strong) NSManagedObjectID *reminderRuleOID;

@end
