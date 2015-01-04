//
//  IMRemindersViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMUI.h"

#import "IMTimeReminderViewController.h"
#import "IMLocationReminderViewController.h"
#import "IMRuleReminderViewController.h"

@interface IMRemindersViewController : IMBaseTableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

// UI
- (void)addReminder:(id)sender;

// Helpers
- (NSInteger)adjustedSectionForSection:(NSInteger)section;

@end
