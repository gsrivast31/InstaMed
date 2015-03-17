//
//  IMTimeReminderViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMTimeReminderViewController.h"
#import "IMAppDelegate.h"

@interface IMTimeReminderViewController ()
{
    NSDateFormatter *timeFormatter;
    NSDateFormatter *dateFormatter;
    
    id reminderUpdateNotifier;
    
    NSString *message;
    NSDate *date;
    NSInteger type;
    NSInteger days;
}

@end

@implementation IMTimeReminderViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Add Reminder", nil);
        
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        type = kReminderTypeDate;
        date = [NSDate date];
        days = 1;
        message = nil;
    }
    return self;
}
- (id)initWithDate:(NSDate *)aDate
{
    self = [self init];
    if (self) {
        date = aDate;
    }
    
    return self;
}
- (id)initWithReminder:(IMReminder *)theReminder
{
    self = [self init];
    if (self) {
        self.title = NSLocalizedString(@"Edit Reminder", nil);
        self.reminder = theReminder;
        
        IMReminder *reminder = (IMReminder *)[self reminder];
        if(reminder)
        {
            type = [reminder.type integerValue];
            date = reminder.date;
            message = reminder.message;
            days = [reminder.days integerValue];
        }
        
        // Ditch out of the edit view if the reminder we're editing is removed
        reminderUpdateNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kRemindersUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            NSArray *existingReminders = [[IMReminderController sharedInstance] fetchAllReminders];

            BOOL reminderStillExists = NO;
            for(NSArray *reminders in existingReminders)
            {
                for(IMReminder *existingReminder in reminders)
                {
                    if([existingReminder isEqual:reminder])
                    {
                        reminderStillExists = YES;
                    }
                }
            }
            
            if(!reminderStillExists)
            {
                [self handleBack:self withSound:NO];
            }
        }];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addReminder:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];

    if(![self reminder])
    {
        [self.tableView reloadData];
        
        IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.accessoryControl becomeFirstResponder];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:reminderUpdateNotifier];
}

#pragma mark - Logic
- (void)addReminder:(id)sender
{
    [self.view endEditing:YES];
    
    NSError *error = nil;
    if((type == kReminderTypeDate && message && [message length] && date) ||
       (type == kReminderTypeRepeating && message && [message length] && date && days))
    {
        NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
        if(moc)
        {
            NSDate *notificationDate = [[IMReminderController sharedInstance] generateNotificationDateWithDate:date];
            if(notificationDate)
            {
                IMReminder *newReminder = (IMReminder *)[self reminder];
                if(!newReminder)
                {
                    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMReminder" inManagedObjectContext:moc];
                    newReminder = (IMReminder *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                    newReminder.created = [NSDate date];
                }
                newReminder.message = message;
                newReminder.date = notificationDate;
                newReminder.type = [NSNumber numberWithInteger:type];
                newReminder.days = [NSNumber numberWithInteger:days];
                
                [moc save:&error];
                if(!error)
                {
                    [[IMReminderController sharedInstance] setNotificationsForReminder:newReminder];
                    
                    // Notify anyone interested that we've updated our reminders
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                    
                    [self handleBack:self withSound:NO];
                }
            }
            else
            {
                error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid reminder date"}];
            }
        }
        else
        {
            error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    else
    {
        error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Please complete all required fields"}];
    }
    
    if(error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"We were unable to save your reminder for the following reason: %@", nil), [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UI
- (void)changeDate:(UIDatePicker *)sender
{
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
     IMInputLabel *inputLabel = (IMInputLabel *)[cell accessoryControl];
    
    date = [sender date];
    [inputLabel setText:[dateFormatter stringFromDate:date]];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)changeTime:(UIDatePicker *)sender
{
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    IMInputLabel *inputLabel = (IMInputLabel *)[cell accessoryControl];
    
    date = [sender date];
    [inputLabel setText:[timeFormatter stringFromDate:date]];
}
- (void)changeType:(UISegmentedControl *)sender
{
    type = [sender selectedSegmentIndex] == 1 ? kReminderTypeDate : kReminderTypeRepeating;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
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
        return 3;
    }
    else
    {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMReminderCell"];
    if (cell == nil)
    {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMReminderCell"];
    }
    cell.textLabel.font = [IMFont standardRegularFontWithSize:16.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:114.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
    
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Time", nil);
            
            IMInputLabel *inputLabel = [[IMInputLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
            inputLabel.text = [timeFormatter stringFromDate:date];
            inputLabel.textAlignment = NSTextAlignmentRight;
            inputLabel.delegate = self;
            inputLabel.font = [IMFont standardMediumFontWithSize:16.0f];
            inputLabel.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
            cell.accessoryView = inputLabel;
            
            UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
            [datePicker setDate:date];
            [datePicker setDatePickerMode:UIDatePickerModeTime];
            [datePicker addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventValueChanged];
            inputLabel.inputView = datePicker;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;            
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Type", nil);
            
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Repeating", nil), NSLocalizedString(@"Date", nil)]];
            segmentedControl.frame = CGRectMake(0.0f, 0.0f, 150.0f, 30.0f);
            segmentedControl.clipsToBounds = YES;
            [segmentedControl addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = segmentedControl;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;            
            
            [segmentedControl setSelectedSegmentIndex:(type == kReminderTypeDate ? 1 : 0)];
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            if(type == kReminderTypeDate)
            {
                cell.textLabel.text = NSLocalizedString(@"Date", nil);
                
                IMInputLabel *inputLabel = [[IMInputLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
                inputLabel.text = [dateFormatter stringFromDate:date];
                inputLabel.textAlignment = NSTextAlignmentRight;
                inputLabel.delegate = self;
                inputLabel.font = [IMFont standardMediumFontWithSize:16.0f];
                inputLabel.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
                cell.accessoryView = inputLabel;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;                
                
                UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
                [datePicker setDate:date];
                [datePicker setDatePickerMode:UIDatePickerModeDate];
                [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
                inputLabel.inputView = datePicker;
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Repeating", @"Label for a reminder which repeats across multiple days");
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
                label.text = [[IMReminderController sharedInstance] formattedRepeatingDaysWithFlags:days];
                label.backgroundColor = [UIColor clearColor];
                label.textAlignment = NSTextAlignmentRight;
                label.font = [IMFont standardMediumFontWithSize:16.0f];
                label.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
                
                cell.accessoryView = label;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
        }
    }
    
    return cell;
}

#pragma mark - IMReminderRepeatDelegate
- (void)setReminderDays:(NSInteger)newValue
{
    days = newValue;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(type == kReminderTypeRepeating)
    {
        if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                IMReminderRepeatViewController *vc = [[IMReminderRepeatViewController alloc] initWithFlags:days];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        message = textField.text;
    }
}

#pragma mark - IMInputLabelDelegate
- (void)inputLabelDidBeginEditing:(IMInputLabel *)inputLabel
{
    UIDatePicker *datePicker = (UIDatePicker *)inputLabel.inputView;
    [datePicker setDate:date];
}

@end