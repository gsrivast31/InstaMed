//
//  IMBGEventRepresentation.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UITextView+Extension.h"
#import "IMBGEventRepresentation.h"
#import "IMNewEventTextBlockViewCell.h"

#import "IMReading.h"

@interface IMBGEventRepresentation ()
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *mgValue;
@property (nonatomic, strong) NSString *mmoValue;

@property (nonatomic, strong) NSString *notes;
@end

@implementation IMBGEventRepresentation

#pragma mark - Setup
- (id)initWithEvent:(IMEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        NSNumberFormatter *valueFormatter = [IMHelper glucoseNumberFormatter];
        IMReading *reading = (IMReading *)[self event];
        if(reading)
        {
            self.mmoValue = [valueFormatter stringFromNumber:reading.mmoValue];
            self.mgValue = [valueFormatter stringFromNumber:reading.mgValue];
            
            NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
            if(unitSetting == BGTrackingUnitMG)
            {
                self.value = self.mgValue;
            }
            else
            {
                self.value = self.mmoValue;
            }
        }
    }
    
    return self;
}
- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"Blood Glucose", nil);
}

#pragma mark - Logic
- (BOOL)saveEvent:(IMEvent **)event error:(NSError **)error
{
    NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        // Convert our input into the right units
        NSNumberFormatter *valueFormatter = [IMHelper glucoseNumberFormatter];
        NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
        if(unitSetting == BGTrackingUnitMG)
        {
            self.mgValue = self.value;
            
            double convertedValue = [[valueFormatter numberFromString:self.mgValue] doubleValue] * 0.0555;
            self.mmoValue = [NSString stringWithFormat:@"%f", convertedValue];
        }
        else
        {
            self.mmoValue = self.value;
            
            double convertedValue = round([[valueFormatter numberFromString:self.mmoValue] doubleValue] * 18.0182);
            self.mgValue = [NSString stringWithFormat:@"%f", convertedValue];
        }
        
        IMReading *reading = (IMReading *)[self event];
        if(!reading)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMReading" inManagedObjectContext:moc];
            reading = (IMReading *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            reading.filterType = [NSNumber numberWithInteger:ReadingFilterType];
            reading.name = NSLocalizedString(@"Blood Glucose", nil);
        }
        reading.mmoValue = [NSNumber numberWithDouble:[[valueFormatter numberFromString:self.mmoValue] doubleValue]];
        reading.mgValue = [NSNumber numberWithDouble:[[valueFormatter numberFromString:self.mgValue] doubleValue]];
        reading.notes = self.notes;
        
        // Let our delegate adjust the IMEvent before it's saved
        if(self.delegate)
        {
            [self.delegate eventRepresentation:self willSaveEvent:(IMEvent *)reading];
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
        
        *event = (IMEvent *)reading;
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
    if(!self.value || ![self.value length])
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please input a Blood Glucose reading", nil) forKey:NSLocalizedDescriptionKey];
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
            
            NSString *placeholder = [NSString stringWithFormat:@"%@ (mg/dL)", NSLocalizedString(@"BG level", @"Blood glucose level")];
            NSInteger units = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
            if(units != BGTrackingUnitMG)
            {
                placeholder = [NSString stringWithFormat:@"%@ (mmoI/L)", NSLocalizedString(@"BG level", @"Blood glucose level")];
            }
            
            UITextField *textField = inputCell.textField;
            textField.placeholder = placeholder;
            textField.text = self.value;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.delegate = self;
            textField.tag = 0;
            textField.inputAccessoryView = nil;
            
            [inputCell.titleLabel setText:NSLocalizedString(@"Value", nil)];
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
        self.value = textField.text;
    }
}
@end
