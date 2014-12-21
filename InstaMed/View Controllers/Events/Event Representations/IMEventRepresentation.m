//
//  IMEventRepresentation.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMEventRepresentation.h"
#import "IMReading.h"

@implementation IMEventRepresentation

- (id)init
{
    self = [super init];
    if(self)
    {
        self.fields = nil;
        self.title = @"Event title";
        
        [self commonInit];
    }
    
    return self;
}
- (id)initWithEvent:(IMEvent *)theEvent
{
    self = [self init];
    if(self)
    {
        self.event = theEvent;
        self.notes = self.event.notes;
        
        [self commonInit];
    }
    
    return self;
}
- (void)commonInit
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IMNewEventTextBlockViewCell" owner:self options:nil];
    for(id object in topLevelObjects)
    {
        if([object isKindOfClass:[IMNewEventTextBlockViewCell class]])
        {
            self.notesViewCell = object;
            break;
        }
    }
    
    dummyNotesTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    dummyNotesTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dummyNotesTextView.scrollEnabled = NO;
    dummyNotesTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    dummyNotesTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    dummyNotesTextView.font = [IMFont standardMediumFontWithSize:16.0f];
}

#pragma mark - Logic
- (BOOL)saveEvent:(IMEvent **)event error:(NSError **)error
{
    return nil;
}
- (BOOL)deleteEvent:(NSError **)error
{
    if(self.event)
    {
        NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            [moc deleteObject:self.event];
            [moc save:&*error];
        }
        else
        {
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    if(*error)
    {
        return NO;
    }
    
    return YES;
}
- (NSError *)validationError
{
    return nil;
}
- (UITableViewCell *)cellForTableView:(UITableView *)tableView withFieldIndex:(NSUInteger)index
{
    return nil;
}
- (CGFloat)heightForCellWithFieldIndex:(NSUInteger)index inTableView:(UITableView *)tableView
{
    return 44.0f;
}
- (NSUInteger)numberOfFields
{
    return 0;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    // Update values
    self.notes = textView.text;
    
    UITableView *tableView = [self.dataSource tableViewForEventRepresentation:self];
    if(tableView)
    {
        [UIView setAnimationsEnabled:NO];
        [tableView beginUpdates];
        [tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
    }
}

@end
