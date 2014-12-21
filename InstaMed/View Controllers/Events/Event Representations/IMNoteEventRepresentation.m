//
//  IMNoteEventRepresentation.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UITextView+Extension.h"
#import "IMNoteEventRepresentation.h"
#import "IMNewEventTextBlockViewCell.h"

#import "IMNote.h"

@interface IMNoteEventRepresentation ()
@property (nonatomic, strong) NSString *notes;
@end

@implementation IMNoteEventRepresentation

#pragma mark - Setup
- (id)initWithEvent:(IMEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        // STUB
    }
    
    return self;
}
- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"Note", nil);
}

#pragma mark - Logic
- (BOOL)saveEvent:(IMEvent **)event error:(NSError **)error
{
    NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        if(!self.title || ![self.title length])
        {
            self.title = NSLocalizedString(@"Note", nil);
        }
        
        IMNote *note = (IMNote *)[self event];
        if(!note)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMNote" inManagedObjectContext:moc];
            note = (IMNote *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            note.filterType = [NSNumber numberWithInteger:NoteFilterType];
        }
        note.name = self.title;
        
        if(!self.notes.length) self.notes = nil;
        note.notes = self.notes;
      
        // Let our delegate adjust the IMEvent before it's saved
        if(self.delegate)
        {
            [self.delegate eventRepresentation:self willSaveEvent:(IMEvent *)note];
        }
        
        /*
        // Save our geotag data
        if(![self.lat isEqual:reading.lat] || ![self.lon isEqual:reading.lon])
        {
            reading.lat = self.lat;
            reading.lon = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:reading.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(reading.photoPath)
            {
                [[IMMediaController sharedInstance] deleteImageWithFilename:reading.photoPath success:nil failure:nil];
            }
            
            reading.photoPath = self.currentPhotoPath;
        }
        */
        
        [moc save:&*error];
        if(*error)
        {
            return NO;
        }
        
        *event = (IMEvent *)note;
        return YES;
    }
    else
    {
        *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        return NO;
    }
}
- (NSError *)validationError
{
    if(!self.title || ![self.title length])
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please input a note title", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    else if(!self.notes || ![self.notes length])
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please input note text", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    
    return nil;
}
- (UITableViewCell *)cellForTableView:(UITableView *)tableView withFieldIndex:(NSUInteger)index
{
    id<IMEventInputFieldProtocol> cell = nil;
    
    switch(index)
    {
        case 0:
        {
            IMNewEventInputViewCell *inputCell = (IMNewEventInputViewCell *)[tableView dequeueReusableCellWithIdentifier:@"IMEventInputViewCell"];
        
            UITextField *textField = inputCell.textField;
            textField.placeholder = NSLocalizedString(@"Title", nil);
            textField.text = self.title;
            textField.delegate = self;
            textField.tag = 0;
            
            [inputCell.titleLabel setText:NSLocalizedString(@"Title", nil)];
            cell = inputCell;
        }
            break;
        case 1:
        {
            IMNewEventTextBlockViewCell *inputCell = self.notesViewCell;
            
            [inputCell.titleLabel setText:NSLocalizedString(@"Notes", nil)];
            inputCell.textView.delegate = self;
            inputCell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            inputCell.textView.text = self.notes;
            
            cell = inputCell;
        }
            break;
    }
    
    return (UITableViewCell *)cell;
}
- (CGFloat)heightForCellWithFieldIndex:(NSUInteger)index inTableView:(UITableView *)tableView
{
    CGFloat height = [super heightForCellWithFieldIndex:index inTableView:tableView];
    if(index == 1)
    {
        height = [self.notesViewCell height];
    }
    
    return height;
}
- (NSUInteger)numberOfFields
{
    return 2;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        self.title = textField.text;
    }
}
@end
