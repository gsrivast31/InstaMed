//
//  IMTimeReminderViewController.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 02/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMUI.h"

#import "IMInputLabel.h"
#import "IMReminderRepeatViewController.h"
#import "IMReminderBaseViewController.h"
#import "IMReminderController.h"

@interface IMTimeReminderViewController : IMReminderBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, IMReminderRepeatDelegate, IMInputLabelDelegate>

// Setup
- (id)initWithDate:(NSDate *)aDate;
- (id)initWithReminder:(IMReminder *)theReminder;

// Logic
- (void)addReminder:(id)sender;

// UI
- (void)changeDate:(UIDatePicker *)sender;
- (void)changeTime:(UIDatePicker *)sender;
- (void)changeType:(UISegmentedControl *)sender;

@end
