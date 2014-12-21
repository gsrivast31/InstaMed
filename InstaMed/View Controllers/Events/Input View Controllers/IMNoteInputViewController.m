//
//  IMNoteInputViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMNoteInputViewController.h"

@interface IMNoteInputViewController ()
{
    NSString *title;
}
@end

@implementation IMNoteInputViewController

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self)
    {
        title = NSLocalizedString(@"Note", nil);
    }
    return self;
}
- (id)initWithEvent:(IMEvent *)aEvent
{
    self = [super initWithEvent:aEvent];
    if(self)
    {
        IMEvent *event = [self event];
        if(event)
        {
            title = event.name;
        }
        else
        {
            title = NSLocalizedString(@"Note", nil);
        }
    }
    
    return self;
}

#pragma mark - Logic
- (NSError *)validationError
{
    if(notes && [notes length])
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
        if(!title || ![title length])
        {
            title = NSLocalizedString(@"Note", nil);
        }
        
        IMNote *note = (IMNote *)[self event];
        if(!note)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMNote" inManagedObjectContext:moc];
            note = (IMNote *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            note.filterType = [NSNumber numberWithInteger:NoteFilterType];
        }
        note.name = title;
        note.timestamp = self.date;
        
        if(!notes.length) notes = nil;
        note.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:note.latitude] || ![self.lon isEqual:note.longitude])
        {
            note.latitude = self.lat;
            note.longitude = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:note.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(note.photoPath)
            {
                [[IMMediaController sharedInstance] deleteImageWithFilename:note.photoPath success:nil failure:nil];
            }
            
            note.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[IMTagController sharedInstance] fetchTagsInString:notes];
        [[IMTagController sharedInstance] assignTags:tags toEvent:note];
        
        [moc save:&*error];
        
        return note;
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

#pragma mark - UI
- (void)changeDate:(id)sender
{
    self.date = [sender date];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
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
        textField.placeholder = NSLocalizedString(@"Title", nil);
        textField.text = title;
        textField.delegate = self;
        textField.inputView = nil;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Title", nil)];
        [cell setDrawsBorder:YES];
    }
    else if(indexPath.row == 1)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Date", nil);
        textField.text = [self.dateFormatter stringFromDate:self.date];
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.delegate = self;
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
        [cell setDrawsBorder:YES];
    }
    else if(indexPath.row == 2)
    {
        IMEventNotesTextView *textView = (IMEventNotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textView.inputView = nil;
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [cell setDrawsBorder:NO];
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
    }
    cell.control.tag = indexPath.row;
}
- (UIImage *)navigationBarBackgroundImage
{
    return [UIImage imageNamed:@"NoteNavBarBG"];
}
- (UIColor *)tintColor
{
    return [UIColor colorWithRed:105.0f/255.0f green:224.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMEventInputViewCell *cell = nil;
    if(indexPath.row == 2)
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
    float height = 0.0;
    if(indexPath.row == 2)
    {
        dummyNotesTextView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width-88.0f, 0.0f);
        dummyNotesTextView.text = notes;
        height = [dummyNotesTextView height];
    }
    
    if(height < 44.0f) height = 44.0f;
    return height;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        title = textField.text;
    }
}

#pragma mark - IMAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(IMAutocompleteBar *)theAutocompleteBar
{
    return [[IMTagController sharedInstance] fetchAllTags];
}

@end
