//
//  IMLocationReminderViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "IMUI.h"
#import "IMReminderController.h"
#import "IMReminderBaseViewController.h"
#import "IMLocationReminderMapViewController.h"

@interface IMLocationReminderViewController : IMReminderBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, IMLocationReminderMapDelegate>

// Setup
- (id)initWithReminder:(IMReminder *)theReminder;

// Logic
- (void)addReminder:(id)sender;
- (void)geolocateUser;

@end
