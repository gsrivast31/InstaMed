//
//  IMMealEventRepresentation.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UITextView+Extension.h"
#import "IMMealEventRepresentation.h"
#import "IMNewEventTextBlockViewCell.h"

#import "IMMeal.h"

@interface IMMealEventRepresentation ()
@property (nonatomic, assign) double grams;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *notes;
@end

@implementation IMMealEventRepresentation

#pragma mark - Setup
- (id)initWithEvent:(IMEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        IMMeal *meal = (IMMeal *)theEvent;
        self.name = meal.name;
        self.grams = [meal.grams doubleValue];
    }
    
    return self;
}
- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"Meal", nil);
}

#pragma mark - Logic
- (BOOL)saveEvent:(IMEvent **)event error:(NSError **)error
{
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
        meal.name = self.name;
        meal.type = @(0);
        meal.grams = @(self.grams);
        
        if(!self.notes.length) self.notes = nil;
        meal.notes = self.notes;
        
        // Let our delegate adjust the IMEvent before it's saved
        if(self.delegate)
        {
            [self.delegate eventRepresentation:self willSaveEvent:(IMEvent *)meal];
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
        
        *event = (IMEvent *)meal;
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
    if(!self.name || ![self.name length])
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please input a meal name", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    else if(self.grams <= 0)
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please enter the total grams in your meal", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    
    return nil;
}
- (UITableViewCell *)cellForTableView:(UITableView *)tableView withFieldIndex:(NSUInteger)index
{
    id<IMEventInputFieldProtocol> cell = nil;
    
    NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
    switch(index)
    {
        case 0:
        {
            IMNewEventInputViewCell *inputCell = (IMNewEventInputViewCell *)[tableView dequeueReusableCellWithIdentifier:@"IMEventInputViewCell"];
            
            UITextField *textField = inputCell.textField;
            textField.placeholder = NSLocalizedString(@"What'd you have?", nil);
            textField.text = self.name;
            textField.tag = 0;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            textField.delegate = self;
            
            [inputCell.titleLabel setText:NSLocalizedString(@"Name", nil)];
            cell = inputCell;
        }
            break;
        case 1:
        {
            IMNewEventInputViewCell *inputCell = (IMNewEventInputViewCell *)[tableView dequeueReusableCellWithIdentifier:@"IMEventInputViewCell"];
            
            UITextField *textField = inputCell.textField;
            textField.placeholder = NSLocalizedString(@"grams (optional)", @"Amount of carbs in grams (this field is optional)");
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.delegate = self;
            textField.tag = 1;
            
            if(self.grams > 0)
            {
                textField.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:self.grams]];
            }
            
            [inputCell.titleLabel setText:NSLocalizedString(@"Carbs", @"Amount of carbohydrates")];
            cell = inputCell;
        }
            break;
        case 2:
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
    if(index == 2)
    {
        height = [self.notesViewCell height];
    }
    
    return height;
}
- (NSUInteger)numberOfFields
{
    return 3;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        self.name = textField.text;
    }
    else if(textField.tag == 1)
    {
        NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
        
        self.grams = [[valueFormatter numberFromString:textField.text] doubleValue];
    }
}
@end
