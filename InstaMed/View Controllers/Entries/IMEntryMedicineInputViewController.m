//
//  IMEntryMedicineInputViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 19/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEntryMedicineInputViewController.h"

#import "IMMediaController.h"
#import "IMTagController.h"

#import "IMEventInputViewCell.h"
#import "IMEventInputTextViewViewCell.h"
#import "IMEventInputTextFieldViewCell.h"
#import "IMEventInputCategoryViewCell.h"
#import "UITextView+Extension.h"
#import "IMCategoryInputView.h"

#import "IMCoreDataStack.h"
#import "IMMedicine.h"

@interface IMEntryMedicineInputViewController () <IMCategoryInputViewDelegate>
{
    NSString *amount;
    NSString *name;
    NSInteger type;
}
@end

@implementation IMEntryMedicineInputViewController

#pragma mark - Setup
- (id)init {
    self = [super init];
    return self;
}

- (id)initWithEvent:(IMEvent *)theEvent {
    self = [super initWithEvent:theEvent];
    if(self) {
        NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
        
        IMMedicine *medicine = (IMMedicine *)theEvent;
        if(medicine) {
            type = [medicine.type integerValue];
            name = medicine.name;
            amount = [valueFormatter stringFromNumber:medicine.amount];
        }
    }
    
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        self.title = @"Edit Medication";
    } else {
        self.title = @"Add Medication";
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage imageNamed:@"MedicineNavBarBG"];
}

- (UIColor *)tintColor {
    return [UIColor colorWithRed:192.0f/255.0f green:138.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

#pragma mark - Logic
- (NSError *)validationError {
    if(amount && [amount length] && name && [name length]) {
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
        NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
        
        IMMedicine *medicine = (IMMedicine *)[self event];
        if(!medicine) {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMMedicine" inManagedObjectContext:moc];
            medicine = (IMMedicine *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            medicine.filterType = [NSNumber numberWithInteger:MedicineFilterType];
        }
        medicine.amount = [valueFormatter numberFromString:amount];
        medicine.name = name;
        medicine.timestamp = self.date;
        medicine.type = [NSNumber numberWithInteger:type];
        
        if(!notes.length) notes = nil;
        medicine.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:medicine.latitude] || ![self.lon isEqual:medicine.longitude]) {
            medicine.latitude = self.lat;
            medicine.longitude = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:medicine.photoPath]) {
            // If a photo already exists for this entry remove it now
            if(medicine.photoPath) {
                [[IMMediaController sharedInstance] deleteImageWithFilename:medicine.photoPath success:nil failure:nil];
            }
            
            medicine.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[IMTagController sharedInstance] fetchTagsInString:notes];
        [[IMTagController sharedInstance] assignTags:tags toEvent:medicine];
        
        [moc save:&*error];
        
        return medicine;
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
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Medication", nil);
        textField.text = name;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Name", nil)];
    } else if(indexPath.row == 1) {
        IMCategoryInputView *control = (IMCategoryInputView *)cell.control;
        control.selectedIndex = type;
        control.delegate = self;
        
        control.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        control.textField.keyboardType = UIKeyboardTypeDecimalPad;
        control.textField.text = amount;
        control.textField.tag = 1;
        control.textField.delegate = self;
        control.textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Amount", nil)];
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
    } else if(indexPath.row == 1) {
        cell = (IMEventInputCategoryViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMEventInputCategoryViewCell"];
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
    
    if(indexPath.row == self.datePickerIndexPath.row) {
        [self.tableView beginUpdates];
        
        if (self.datePickerVisible) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row+1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row+1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.datePickerVisible = !self.datePickerVisible;
        [self.tableView endUpdates];
    }
}

#pragma mark - IMCategoryInputViewDelegate methods
- (void)categoryInputView:(IMCategoryInputView *)categoryInputView didSelectOption:(NSUInteger)index {
    type = index;
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
        name = textField.text;
    }
    else if(textField.tag == 1) {
        amount = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newValue = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField.tag == 2) {
        return NO;
    } else if(textField.tag == 0) {
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:newValue];
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
