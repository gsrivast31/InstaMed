//
//  IMActivityInputViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 05/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMActivityInputViewController.h"

#define kDatePickerViewTag 1
#define kToolbarViewTag 2
#define kNameInputControlTag 3
#define kMinutesInputControlTag 4
#define kDateInputControlTag 5
#define kIconTag 6

@interface IMActivityInputViewController ()
{
    NSString *name;
    NSString *minutes;
}
@end

@implementation IMActivityInputViewController

#pragma mark - Setup
- (id)initWithEvent:(IMEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        IMActivity *activity = (IMActivity *)[self event];
        if(activity)
        {
            name = activity.name;
            minutes = [NSString stringWithFormat:@"%.0f", [activity.minutes doubleValue]];
        }
    }
    
    return self;
}

#pragma mark - Logic
- (NSError *)validationError
{
    if(name && [name length])
    {
        if([self.date compare:[NSDate date]] != NSOrderedAscending)
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:NSLocalizedString(@"You cannot enter an event in the future", nil) forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
        }
    }
    else
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please complete all required fields", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    
    return nil;
}
- (IMEvent *)saveEvent:(NSError **)error
{
    [self.view endEditing:YES];

    NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        IMActivity *activity = (IMActivity *)[self event];
        if(!activity)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMActivity" inManagedObjectContext:moc];
            activity = (IMActivity *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            activity.filterType = [NSNumber numberWithInteger:ActivityFilterType];
        }
        activity.name = name;
        activity.timestamp = self.date;
        activity.minutes = [NSNumber numberWithDouble:[minutes doubleValue]];
        
        if(!notes.length) notes = nil;
        activity.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:activity.latitude] || ![self.lon isEqual:activity.longitude])
        {
            activity.latitude = self.lat;
            activity.longitude = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:activity.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(activity.photoPath)
            {
                [[IMMediaController sharedInstance] deleteImageWithFilename:activity.photoPath success:nil failure:nil];
            }
            
            activity.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[IMTagController sharedInstance] fetchTagsInString:notes];
        [[IMTagController sharedInstance] assignTags:tags toEvent:activity];
        
        [moc save:&*error];
        return activity;
    }
    else
    {
        if(error)
        {
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    return nil;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
     
    [self.tableView registerClass:[IMEventInputTextViewViewCell class] forCellReuseIdentifier:@"IMEventInputTextViewViewCell"];
    [self.tableView registerClass:[IMEventInputTextFieldViewCell class] forCellReuseIdentifier:@"IMEventTextFieldViewCell"];
    [self.tableView registerClass:[IMEventInputCategoryViewCell class] forCellReuseIdentifier:@"IMEventInputCategoryViewCell"];
    [self.tableView registerClass:[IMEventDateTimeViewCell class] forCellReuseIdentifier:@"IMEventDateTimeViewCell"];
    [self.tableView registerClass:[IMEventInputLabelViewCell class] forCellReuseIdentifier:@"IMEventInputLabelViewCell"];
     
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)changeDate:(id)sender
{
    self.date = [sender date];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell)
    {
        UITextField *textField = (UITextField *)cell.control;
        [textField setText:[self.dateFormatter stringFromDate:self.date]];
    }
}
- (void)configureAppearanceForTableViewCell:(IMEventInputViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell resetCell];
    
    if(indexPath.row == 0)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Activity", @"Activity (physical exercise)");
        textField.text = name;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Name", nil)];
    }
    else if(indexPath.row == 1)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Minutes", nil);
        textField.text = minutes;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Time", nil)];
    }
    else if(indexPath.row == 2)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Date", nil);
        textField.text = [self.dateFormatter stringFromDate:self.date];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.delegate = self;
        textField.inputAccessoryView = nil;
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker setDate:self.date];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    }
    else if(indexPath.row == 3)
    {
        IMEventNotesTextView *textView = (IMEventNotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textView.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    
    cell.control.tag = indexPath.row;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage imageNamed:@"ActivityNavBarBG"];
}

- (UIColor *)tintColor {
    return [UIColor colorWithRed:127.0f/255.0f green:192.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMEventInputViewCell *cell = nil;
    if(indexPath.row == 3) {
        cell = (IMEventInputTextViewViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMEventInputTextViewViewCell"];
        if (!cell) {
            cell = [[IMEventInputTextViewViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMEventInputTextViewViewCell"];
        }
    } else {
        cell = (IMEventInputTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMEventTextFieldViewCell"];
        if (!cell) {
            cell = [[IMEventInputTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMEventTextFieldViewCell"];
        }
    }
    
    [self configureAppearanceForTableViewCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [super tableView:aTableView heightForRowAtIndexPath:indexPath];
    if(indexPath.row == 3) {
        dummyNotesTextView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width-88.0f, 0.0f);
        dummyNotesTextView.text = notes;
        height = [dummyNotesTextView height];
    } else if(indexPath.row == 4) {
        height = 170.0f;
    }
    
    if(height < 44.0f) height = 44.0f;
    return height;
}

#pragma mark - IMAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(IMAutocompleteBar *)theAutocompleteBar {
    if(self.activeControlIndexPath.row == 0) {
        return [[IMEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:ActivityFilterType];
    } else {
        return [[IMTagController sharedInstance] fetchAllTags];
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.tag == 0) {
        name = textField.text;
    } else if(textField.tag == 1) {
        minutes = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.tag == 2) {
        return NO;
    } else if(textField.tag == 0) {
        NSString *fullText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:fullText];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if(textField.tag == 0) {
        [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    }
    
    return YES;
}

@end
