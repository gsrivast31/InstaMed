//
//  IMEntryBPReadingInputViewController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEntryBPReadingInputViewController.h"
#import "IMMediaController.h"
#import "IMTagController.h"

#import "IMEventInputViewCell.h"
#import "IMEventInputTextViewViewCell.h"
#import "IMEventInputTextFieldViewCell.h"
#import "UITextView+Extension.h"

#import "IMCoreDataStack.h"
#import "IMBPReading.h"

@interface IMEntryBPReadingInputViewController ()
{
    uint lowValue;
    uint highValue;
}
@end

@implementation IMEntryBPReadingInputViewController

#pragma mark - Setup
- (id)init {
    self = [super init];
    eventFilterType = BPReadingFilterType;
    
    return self;
}

- (id)initWithEvent:(IMEvent *)theEvent {
    self = [super initWithEvent:theEvent];
    if(self) {
        eventFilterType = BPReadingFilterType;
        
        IMBPReading *reading = (IMBPReading *)[self event];
        if(reading) {
            lowValue = [reading.lowValue unsignedIntValue];
            highValue = [reading.highValue unsignedIntValue];
        }
    }
    
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        self.title = @"Edit BP Reading";
    } else {
        self.title = @"Add BP Reading";
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage imageNamed:@"ReadingNavBarBG"];
}

- (UIColor *)tintColor {
    return [UIColor colorWithRed:254.0f/255.0f green:96.0f/255.0f blue:111.0f/255.0f alpha:1.0f];
}

#pragma mark - Logic
- (NSError *)validationError {
    if(lowValue > 0 && highValue > lowValue) {
        if([self.date compare:[NSDate date]] != NSOrderedAscending) {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:NSLocalizedString(@"You cannot enter an event in the future", nil) forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
        }
    } else {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please complete all required fields", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    
    return nil;
}

- (IMEvent *)saveEvent:(NSError **)error {
    [self.view endEditing:YES];
    
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        IMBPReading *reading = (IMBPReading *)[self event];
        if(!reading) {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMBPReading" inManagedObjectContext:moc];
            reading = (IMBPReading *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            reading.filterType = [NSNumber numberWithInteger:BPReadingFilterType];
            reading.name = NSLocalizedString(@"Blood Pressure Reading", nil);
        }
        reading.lowValue = [NSNumber numberWithUnsignedInt:lowValue];
        reading.highValue = [NSNumber numberWithUnsignedInt:highValue];
        reading.timestamp = self.date;
        
        if(!notes.length) notes = nil;
        reading.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:reading.latitude] || ![self.lon isEqual:reading.longitude]) {
            reading.latitude = self.lat;
            reading.longitude = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:reading.photoPath]) {
            // If a photo already exists for this entry remove it now
            if(reading.photoPath) {
                [[IMMediaController sharedInstance] deleteImageWithFilename:reading.photoPath success:nil failure:nil];
            }
            
            reading.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[IMTagController sharedInstance] fetchTagsInString:notes];
        [[IMTagController sharedInstance] assignTags:tags toEvent:reading];
        
        [moc save:&*error];
        
        return reading;
    } else {
        if(error) {
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    return nil;
}

#pragma mark - UI

- (void)configureAppearanceForTableViewCell:(IMEventInputViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell resetCell];
    
    NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
    
    if(indexPath.row == 0) {
        NSString *placeholder = [NSString stringWithFormat:@"%@ (mm Hg)", NSLocalizedString(@"Lower BP reading", @"Lower Blood pressure reading")];
        
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = placeholder;
        
        if (lowValue > 0) {
            textField.text = [valueFormatter stringFromNumber:[NSNumber numberWithUnsignedInt:lowValue]];
        }
        
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.tag = 0;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Low", nil)];
    } else if(indexPath.row == 1) {
        NSString *placeholder = [NSString stringWithFormat:@"%@ (mm Hg)", NSLocalizedString(@"Higher BP reading", @"HIgher Blood pressure reading")];
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = placeholder;
        
        if (highValue > 0) {
            textField.text = [valueFormatter stringFromNumber:[NSNumber numberWithUnsignedInt:highValue]];
        }
        
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.tag = 1;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"High", nil)];
    } else if(indexPath.row == 2) {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Date", nil);
        textField.text = [self.dateFormatter stringFromDate:self.date];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.delegate = self;
        textField.inputAccessoryView = nil;
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    } else if(indexPath.row == 3) {
        IMEventNotesTextView *textView = (IMEventNotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textView.inputAccessoryView = [self keyboardShortcutAccessoryView];
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    
    cell.control.tag = indexPath.row;
}

- (void)changeDate:(id)sender {
    self.date = [sender date];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell) {
        UITextField *textField = (UITextField *)cell.control;
        [textField setText:[self.dateFormatter stringFromDate:self.date]];
    }
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
    } else {
        cell = (IMEventInputTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMEventTextFieldViewCell"];
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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if([cell respondsToSelector:@selector(control)]) {
        [cell.control becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.keyboardShortcutAccessoryView.autocompleteBar.shouldFetchSuggestions = YES;
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    
    [textField reloadInputViews];
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    [self updateUI];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.tag == 0) {
        NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
        lowValue = [[valueFormatter numberFromString:textField.text] unsignedIntValue];
    } else if(textField.tag == 1) {
        NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
        highValue = [[valueFormatter numberFromString:textField.text] unsignedIntValue];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.tag == 2) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if(textField.tag == 0 || textField.tag == 1) {
        [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    }
    
    return YES;
}

@end
