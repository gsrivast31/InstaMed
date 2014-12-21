//
//  IMEntryMealInputViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 19/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEntryMealInputViewController.h"
#import "IMMediaController.h"
#import "IMTagController.h"

#import "IMEventInputViewCell.h"
#import "IMEventInputTextViewViewCell.h"
#import "IMEventInputTextFieldViewCell.h"
#import "UITextView+Extension.h"

#import "IMCoreDataStack.h"
#import "IMMeal.h"

@interface IMEntryMealInputViewController ()
{
    NSString *name;
    double grams;
}
@end

@implementation IMEntryMealInputViewController

#pragma mark - Setup
- (id)init {
    self = [super init];
    return self;
}

- (id)initWithEvent:(IMEvent *)theEvent {
    self = [super initWithEvent:theEvent];
    if(self) {
        IMMeal *meal = (IMMeal *)[self event];
        if(meal) {
            name = meal.name;
            grams = [meal.grams doubleValue];
        }
    }
    
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        self.title = @"Edit Meal";
    } else {
        self.title = @"Add Meal";
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage imageNamed:@"MealNavBarBG"];
}

- (UIColor *)tintColor {
    return [UIColor colorWithRed:254.0f/255.0f green:201.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
}

#pragma mark - Logic
- (NSError *)validationError {
    if(name && [name length]) {
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
        IMMeal *meal = (IMMeal *)[self event];
        if(!meal) {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMMeal" inManagedObjectContext:moc];
            meal = (IMMeal *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            meal.filterType = [NSNumber numberWithInteger:MealFilterType];
        }
        meal.name = name;
        meal.timestamp = self.date;
        meal.type = [NSNumber numberWithInteger:0];
        meal.grams = [NSNumber numberWithDouble:grams];
        
        if(!notes.length) notes = nil;
        meal.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:meal.latitude] || ![self.lon isEqual:meal.longitude]) {
            meal.latitude = self.lat;
            meal.longitude = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:meal.photoPath]) {
            // If a photo already exists for this entry remove it now
            if(meal.photoPath) {
                [[IMMediaController sharedInstance] deleteImageWithFilename:meal.photoPath success:nil failure:nil];
            }
            
            meal.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[IMTagController sharedInstance] fetchTagsInString:notes];
        [[IMTagController sharedInstance] assignTags:tags toEvent:meal];
        
        [moc save:&*error];
        
        return meal;
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
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"What'd you have?", nil);
        textField.text = name;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Name", nil)];
    } else if(indexPath.row == 1) {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"grams (optional)", @"Amount of carbs in grams (this field is optional)");
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.inputAccessoryView = nil;
        
        if(grams > 0) {
            textField.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:grams]];
        }
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Carbs", @"Amount of carbohydrates")];
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
    } else if(textField.tag == 1) {
        NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
        grams = [[valueFormatter numberFromString:textField.text] doubleValue];
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
