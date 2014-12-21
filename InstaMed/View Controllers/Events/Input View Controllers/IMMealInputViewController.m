//
//  IMMealInputViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 05/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMMealInputViewController.h"
#import "IMEventInputTextFieldViewCell.h"
#import "IMEventInputTextViewViewCell.h"
#import "IMAppDelegate.h"

@interface IMMealInputViewController ()
{
    UITextField *nameTextField;
    
    NSString *name;
    double grams;
}
@property (nonatomic, assign) NSInteger type;
@end

@implementation IMMealInputViewController
@synthesize type = _type;

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self)
    {
        _type = 0;
        grams = 0;
    }
    return self;
}
- (id)initWithEvent:(IMEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        IMMeal *meal = (IMMeal *)[self event];
        if(meal)
        {
            name = meal.name;
            grams = [meal.grams doubleValue];
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
        IMMeal *meal = (IMMeal *)[self event];
        if(!meal)
        {
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
        if(![self.lat isEqual:meal.latitude] || ![self.lon isEqual:meal.longitude])
        {
            meal.latitude = self.lat;
            meal.longitude = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:meal.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(meal.photoPath)
            {
                [[IMMediaController sharedInstance] deleteImageWithFilename:meal.photoPath success:nil failure:nil];
            }
            
            meal.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[IMTagController sharedInstance] fetchTagsInString:notes];
        [[IMTagController sharedInstance] assignTags:tags toEvent:meal];
        
        [moc save:&*error];
        
        return meal;
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
- (BOOL)disablesAutomaticKeyboardDismissal
{
    return YES;
}
- (BOOL)canResignFirstResponder {
    return NO;
}
// UI
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
    
    NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
    if(indexPath.row == 0)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"What'd you have?", nil);
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
        textField.placeholder = NSLocalizedString(@"grams (optional)", @"Amount of carbs in grams (this field is optional)");
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.inputAccessoryView = nil;
        
        if(grams > 0)
        {
            textField.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:grams]];
        }
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Carbs", @"Amount of carbohydrates")];
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
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
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
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    cell.control.tag = indexPath.row;
}

#pragma mark - UI
- (UIImage *)navigationBarBackgroundImage
{
    return [UIImage imageNamed:@"MealNavBarBG"];
}
- (UIColor *)tintColor
{
    return [UIColor colorWithRed:254.0f/255.0f green:201.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMEventInputViewCell *cell = nil;
    if(indexPath.row == 3)
    {
        cell = (IMEventInputTextViewViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMEventInputTextViewViewCell"];
    }
    else
    {
        cell = (IMEventInputTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMEventTextFieldViewCell"];
    }
    
    [self configureAppearanceForTableViewCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:aTableView heightForRowAtIndexPath:indexPath];
    if(indexPath.row == 3)
    {
        dummyNotesTextView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width-88.0f, 0.0f);
        dummyNotesTextView.text = notes;
        height = [dummyNotesTextView height];
    }
    else if(indexPath.row == 4)
    {
        height = 170.0f;
    }
    
    if(height < 44.0f) height = 44.0f;    
    return height;
}

#pragma mark - IMAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(IMAutocompleteBar *)theAutocompleteBar
{
    if(self.activeControlIndexPath.row == 0)
    {
        return [[IMEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:MealFilterType];
    }
    else
    {
        return [[IMTagController sharedInstance] fetchAllTags];
    }
    
    return nil;
}
- (void)autocompleteBar:(IMAutocompleteBar *)theAutocompleteBar didSelectSuggestion:(NSString *)suggestion
{
    if(self.activeControlIndexPath.row == 0)
    {
        __weak typeof(self) weakSelf = self;
        
        // If we're auto-selecting a previous meal, fetch and populate it's carb count too!
        NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            [moc performBlockAndWait:^{
                
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMEvent" inManagedObjectContext:moc];
                [request setEntity:entity];
                [request setReturnsDistinctResults:YES];
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
                [request setSortDescriptors:@[sortDescriptor]];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType == %d && name == %@", MealFilterType, suggestion];
                [request setPredicate:predicate];
                
                NSError *error = nil;
                NSArray *objects = [moc executeFetchRequest:request error:&error];
                if (objects != nil && [objects count] > 0)
                {
                    IMMeal *meal = (IMMeal *)objects[0];
                    if(meal)
                    {
                        grams = [meal.grams doubleValue];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            __strong typeof(weakSelf) strongSelf = self;
                            [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        });
                    }
                }
            }];
        }
    }
    
    [super autocompleteBar:theAutocompleteBar didSelectSuggestion:suggestion];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        name = textField.text;
    }
    else if(textField.tag == 1)
    {
        NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
        
        grams = [[valueFormatter numberFromString:textField.text] doubleValue];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 2)
    {
        return NO;
    }
    else if(textField.tag == 0)
    {
        NSString *fullText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:fullText];
    }
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    }
    
    return YES;
}

@end
