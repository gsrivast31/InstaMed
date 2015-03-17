//
//  IMEntryCholesterolInputViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEntryCholesterolInputViewController.h"

#import "IMMediaController.h"
#import "IMTagController.h"

#import "IMEventInputViewCell.h"
#import "IMEventInputTextViewViewCell.h"
#import "IMEventInputTextFieldViewCell.h"
#import "UITextView+Extension.h"

#import "IMCoreDataStack.h"
#import "IMCholesterolReading.h"

@interface IMEntryCholesterolInputViewController ()
{
    NSString *value;
    NSString *mgValue;
    NSString *mmoValue;
}
@end

@implementation IMEntryCholesterolInputViewController


#pragma mark - Setup
- (id)init {
    self = [super init];
    eventFilterType = CholesterolReadingFilterType;
    
    return self;
}

- (id)initWithEvent:(IMEvent *)theEvent {
    self = [super initWithEvent:theEvent];
    if(self) {
        eventFilterType = CholesterolReadingFilterType;
        
        NSNumberFormatter *valueFormatter = [IMHelper glucoseNumberFormatter];
        IMCholesterolReading *reading = (IMCholesterolReading *)[self event];
        if(reading) {
            mmoValue = [valueFormatter stringFromNumber:reading.mmoValue];
            mgValue = [valueFormatter stringFromNumber:reading.mgValue];
            
            NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
            if(unitSetting == ChTrackingUnitMG) {
                value = mgValue;
            } else {
                value = mmoValue;
            }
        }
    }
    
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        self.title = @"Edit Reading";
    } else {
        self.title = @"Add Reading";
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
    if(value && [value length]) {
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
        // Convert our input into the right units
        NSNumberFormatter *valueFormatter = [IMHelper glucoseNumberFormatter];
        NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
        if(unitSetting == ChTrackingUnitMG) {
            mgValue = value;
            
            double convertedValue = [[valueFormatter numberFromString:mgValue] doubleValue] * 0.0555;
            mmoValue = [NSString stringWithFormat:@"%f", convertedValue];
        } else {
            mmoValue = value;
            
            double convertedValue = round([[valueFormatter numberFromString:mmoValue] doubleValue] * 18.0182);
            mgValue = [NSString stringWithFormat:@"%f", convertedValue];
        }
        
        IMCholesterolReading *reading = (IMCholesterolReading *)[self event];
        if(!reading) {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMCholesterolReading" inManagedObjectContext:moc];
            reading = (IMCholesterolReading *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            reading.filterType = [NSNumber numberWithInteger:CholesterolReadingFilterType];
            reading.name = NSLocalizedString(@"Cholesterol level", nil);
        }
        reading.mmoValue = [NSNumber numberWithDouble:[[valueFormatter numberFromString:mmoValue] doubleValue]];
        reading.mgValue = [NSNumber numberWithDouble:[[valueFormatter numberFromString:mgValue] doubleValue]];
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
    
    if(indexPath.row == 0) {
        NSString *placeholder = [NSString stringWithFormat:@"%@ (mg/dL)", NSLocalizedString(@"Cholesterol level", @"Cholesterol level")];
        NSInteger units = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
        if(units != ChTrackingUnitMG) {
            placeholder = [NSString stringWithFormat:@"%@ (mmoI/L)", NSLocalizedString(@"Cholesterol level", @"Cholesterol level")];
        }
        
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = placeholder;
        textField.text = value;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Value", nil)];
    } else if(indexPath.row == 1) {
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
    } else if(indexPath.row == 2) {
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMEventInputViewCell *cell = nil;
    if(indexPath.row == 2) {
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
        value = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.tag == 1) {
        return NO;
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
