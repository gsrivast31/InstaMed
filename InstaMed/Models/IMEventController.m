//
//  IMEventController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 18/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "NSDate+Extension.h"

#import "IMEventController.h"
#import "IMTagController.h"

#import "IMBGReading.h"
#import "IMBPReading.h"
#import "IMCholesterolReading.h"
#import "IMWeightReading.h"
#import "IMMedicine.h"
#import "IMMeal.h"
#import "IMActivity.h"

@interface IMEventController ()
@property (nonatomic, strong) NSManagedObjectContext *moc;
@end

@implementation IMEventController
@synthesize moc = _moc;

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)setMOC:(NSManagedObjectContext *)aMOC {
    _moc = aMOC;
}

#pragma mark - Events
- (void)attemptSmartInputWithExistingEntries:(NSMutableArray *)existingEntries
                                     success:(void (^)(IMMedicine*))successBlock
                                     failure:(void (^)(void))failureBlock {
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        [moc performBlock:^{

            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMMedicine" inManagedObjectContext:moc];
            [request setEntity:entity];
            
            NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];

            // Fetch all medication inputs over the past 15 days
            NSDate *timestamp = [[[NSDate date] dateAtStartOfDay] dateBySubtractingDays:15];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ && userGuid = %@", timestamp, currentUserGuid];
            [request setPredicate:predicate];
            
            NSInteger hourInterval = 3;
            NSInteger numberOfSegments = 24/(hourInterval*2);
            
            // Execute the fetch.
            NSError *error = nil;
            NSMutableArray *objects = [NSMutableArray array];
            NSArray *results = [moc executeFetchRequest:request error:&error];
            if(results) {
                [objects addObjectsFromArray:results];
            }
            if(existingEntries) {
                [objects addObjectsFromArray:existingEntries];
            }
            
            if (objects != nil && [objects count] > 0) {
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *currentComponents = [gregorianCalendar components:NSCalendarUnitHour fromDate:[NSDate date]];
                NSInteger currentHour = [currentComponents hour];
                
                // Create an event array index for each medicine 'type'
                NSMutableArray *previousEvents = [NSMutableArray array];
                NSMutableArray *todaysEvents = [NSMutableArray array];
                for(NSInteger i = 0; i < numberOfSegments; i++) {
                    [previousEvents addObject:[NSMutableArray array]];
                    [todaysEvents addObject:[NSMutableArray array]];
                }
                
                // Iterate over all medicine events that have taken place over the past 15 days
                for(IMMedicine *event in objects) {
                    NSDateComponents *eventComponents = [gregorianCalendar components:NSCalendarUnitHour fromDate:[event timestamp]];
                    NSInteger eventHour = [eventComponents hour];
                    
                    // If this event occurred today, remove it from the rest of the group
                    if([[event timestamp] isEqualToDateIgnoringTime:[NSDate date]]) {
                        NSMutableArray *existingEvents = [todaysEvents objectAtIndex:[[event type] integerValue]];
                        [existingEvents addObject:event];
                        [todaysEvents replaceObjectAtIndex:[[event type] integerValue] withObject:existingEvents];
                    } else {
                        // Did this event happen within 3 hours (irrespective of date) from the current time?
                        if(fabs(eventHour-currentHour) <= numberOfSegments-1) {
                            NSMutableArray *existingEvents = [previousEvents objectAtIndex:[[event type] integerValue]];
                            [existingEvents addObject:event];
                            [previousEvents replaceObjectAtIndex:[[event type] integerValue] withObject:existingEvents];
                        }
                    }
                }
                
                // Loop through today's events and try to determine what has already been entered
                for(NSInteger i = 0; i < numberOfSegments; i++) {
                    NSMutableArray *events = [todaysEvents objectAtIndex:i];
                    if([events count]) {
                        // Loop through all of the events of this type that occurred today
                        NSMutableArray *pEvents = [previousEvents objectAtIndex:i];
                        for(IMMedicine *event in events) {
                            // Loop through previous events of this type
                            for(IMMedicine *pEvent in [pEvents copy]) {
                                // Determine whether this previous event is similar to the medicine taken earlier today
                                // If it is, remove it from consideration
                                NSString *eventDesc = [[event name] lowercaseString];
                                NSString *pEventDesc = [[pEvent name] lowercaseString];
                                if([eventDesc levenshteinDistanceToString:pEventDesc] <= 3) {
                                    NSDateComponents *eventComponents = [gregorianCalendar components:NSCalendarUnitHour fromDate:[event timestamp]];
                                    NSInteger eventHour = [eventComponents hour];
                                    
                                    // Remove any medication taken within 3 hours of this date/time
                                    if(fabs(eventHour-currentHour) <= numberOfSegments-1) {
                                        [pEvents removeObject:pEvent];
                                    }
                                }
                            }
                        }
                        [previousEvents replaceObjectAtIndex:i withObject:pEvents];
                    }
                }
                
                NSMutableArray *sortedEvents = [NSMutableArray arrayWithArray:[previousEvents sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSNumber *first = [NSNumber numberWithInteger:[a count]];
                    NSNumber *second = [NSNumber numberWithInteger:[b count]];
                    return [first compare:second];
                }]];
                for(NSInteger i = numberOfSegments-1; i >= 0; i--) {
                    NSMutableArray *events = [sortedEvents objectAtIndex:i];
                    
                    // Only choose an event if there's more than 1 instance of it (experimental)
                    if([events count] > 1) {
                        successBlock((IMMedicine *)[events objectAtIndex:0]);
                        return;
                    } else {
                        // Uh oh, better get out of here
                        break;
                    }
                }
                
                failureBlock();
            } else {
                // No objects to perform Smart Input with
                failureBlock();
            }
        }];
    } else {
        failureBlock();
    }
}

- (NSArray *)fetchEventsWithPredicate:(NSPredicate *)predicate
                      sortDescriptors:(NSArray *)sortDescriptors
                            inContext:(NSManagedObjectContext *)moc {
    __block NSArray *returnArray = nil;
    
    [moc performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMEvent" inManagedObjectContext:moc];
        [request setEntity:entity];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            returnArray = objects;
        }
    }];
    return returnArray;
}

- (NSDictionary *)statisticsForEvents:(NSArray *)events fromDate:(NSDate *)minDate toDate:(NSDate *)maxDate {
    NSInteger totalGrams = 0, totalMinutes = 0, totalBGReadings = 0;
    NSInteger totalChReadings = 0, totalBPReadings = 0, totalWtReadings = 0;
    double lowestBGReading = 99999.9, highestBGReading = 0.0f, readingsBGTotal = 0.0f;
    double lowestChReading = 99999.9, highestChReading = 0.0f, readingsChTotal = 0.0f;
    double lowestWtReading = 99999.9, highestWtReading = 0.0f;
    uint highestBPReading = 0, lowestBPReading = UINT_MAX;
    
    NSMutableArray *readingValues = [NSMutableArray array];
    for(IMEvent *event in events) {
        NSDate *timestamp = [event valueForKey:@"timestamp"];
        if([timestamp isEarlierThanDate:maxDate] && [timestamp isLaterThanDate:minDate]) {
            if([event isKindOfClass:[IMBGReading class]]) {
                IMBGReading *reading = (IMBGReading *)event;
                
                double readingValue = [[reading value] doubleValue];
                readingsBGTotal += readingValue;
                
                if(readingValue > highestBGReading) highestBGReading = readingValue;
                if(readingValue < lowestBGReading) lowestBGReading = readingValue;
                
                [readingValues addObject:[NSNumber numberWithDouble:readingValue]];
                
                totalBGReadings ++;
            } else if ([event isKindOfClass:[IMBPReading class]]) {
                IMBPReading *reading = (IMBPReading *)event;
                
                uint lowReadingValue = [[reading lowValue] unsignedIntValue];
                uint highReadingValue = [[reading highValue] unsignedIntValue];
                
                if (lowReadingValue < lowestBPReading) lowestBPReading = lowReadingValue;
                if (highReadingValue > highestBPReading) highestBPReading = highReadingValue;
                
                totalBPReadings ++;
            } else if ([event isKindOfClass:[IMCholesterolReading class]]) {
                IMCholesterolReading *reading = (IMCholesterolReading*)event;
                double readingValue = [[reading value] doubleValue];
                readingsChTotal += readingValue;
                
                if(readingValue > highestChReading) highestChReading = readingValue;
                if(readingValue < lowestChReading) lowestChReading = readingValue;
                
                [readingValues addObject:[NSNumber numberWithDouble:readingValue]];
                
                totalChReadings ++;
            } else if ([event isKindOfClass:[IMWeightReading class]]) {
                IMWeightReading *reading = (IMWeightReading*)event;
                double readingValue = [[reading value] doubleValue];
                
                if (lowestWtReading > readingValue) lowestWtReading = readingValue;
                if (highestWtReading < readingValue) highestWtReading = readingValue;
                
                totalWtReadings ++;
            } else if([event isKindOfClass:[IMMeal class]]) {
                IMMeal *meal = (IMMeal *)event;
                totalGrams += [[meal grams] integerValue];
            } else if([event isKindOfClass:[IMActivity class]]) {
                IMActivity *activity = (IMActivity *)event;
                totalMinutes += [[activity minutes] integerValue];
            }
        }
    }
    
    double readingsBGAvg = 0;
    double readingsBGDeviation = 0;
    if(totalBGReadings <= 0) {
        lowestBGReading = 0.0f;
        highestBGReading = 0.0f;
    } else {
        readingsBGAvg = readingsBGTotal / totalBGReadings;
        for(NSNumber *reading in readingValues) {
            double diff = fabs([reading doubleValue] - readingsBGAvg);
            readingsBGDeviation += diff;
        }
        readingsBGDeviation /= totalBGReadings;
    }

    double readingsChAvg = 0;
    double readingsChDeviation = 0;
    if(totalChReadings <= 0) {
        lowestChReading = 0.0f;
        highestChReading = 0.0f;
    } else {
        readingsChAvg = readingsChTotal / totalChReadings;
        for(NSNumber *reading in readingValues) {
            double diff = fabs([reading doubleValue] - readingsChAvg);
            readingsChDeviation += diff;
        }
        readingsChDeviation /= totalChReadings;
    }

    if (totalWtReadings <= 0) {
        lowestWtReading = highestWtReading = 0.0f;
    }
    
    if (totalBPReadings <= 0) {
        lowestBPReading = highestBPReading = 0.0f;
    }
    return @{
             kMinDateKey: minDate,
             kMaxDateKey: maxDate,
             kTotalGramsKey: [NSNumber numberWithInteger:totalGrams],
             kTotalMinutesKey: [NSNumber numberWithInteger:totalMinutes],
             kBGReadingsDeviationKey: [NSNumber numberWithDouble:readingsBGDeviation],
             kBGReadingsAverageKey: [NSNumber numberWithDouble:readingsBGAvg],
             kBGReadingsTotalKey: [NSNumber numberWithInteger:totalBGReadings],
             kBGReadingLowestKey: [NSNumber numberWithDouble:lowestBGReading],
             kBGReadingHighestKey: [NSNumber numberWithDouble:highestBGReading],
             kChReadingsDeviationKey: [NSNumber numberWithDouble:readingsChDeviation],
             kChReadingsAverageKey: [NSNumber numberWithDouble:readingsChAvg],
             kChReadingsTotalKey: [NSNumber numberWithInteger:totalChReadings],
             kChReadingLowestKey: [NSNumber numberWithDouble:lowestChReading],
             kChReadingHighestKey: [NSNumber numberWithDouble:highestChReading],
             kBPReadingLowestKey: [NSNumber numberWithUnsignedInt:lowestBPReading],
             kBPReadingHighestKey: [NSNumber numberWithUnsignedInt:highestBPReading],
             kWtReadingLowestKey: [NSNumber numberWithDouble:lowestWtReading],
             kWtReadingHighestKey: [NSNumber numberWithDouble:highestWtReading],
             kEventsKey: events
             };
}

- (NSArray *)fetchKey:(NSString *)key forEventsWithFilterType:(EventFilterType)filterType
{
    __block NSArray *returnArray = nil;
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] newPrivateContext];
    if(moc) {
        [moc performBlockAndWait:^{

            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMEvent" inManagedObjectContext:moc];
            [request setEntity:entity];
            [request setResultType:NSDictionaryResultType];
            
            NSExpression *valueExpression = [NSExpression expressionForKeyPath:key];
            NSExpressionDescription *valueDescription = [[NSExpressionDescription alloc] init];
            [valueDescription setName:@"value"];
            [valueDescription setExpression:valueExpression];
            [valueDescription setExpressionResultType:NSStringAttributeType];
            [request setPropertiesToFetch:@[valueDescription]];
            [request setReturnsDistinctResults:YES];
            
            NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType == %d && userGuid = %@", filterType, currentUserGuid];
            [request setPredicate:predicate];
            
            // Execute the fetch.
            NSError *error = nil;
            NSMutableArray *results = [NSMutableArray array];
            NSArray *objects = [moc executeFetchRequest:request error:&error];
            if (objects != nil && [objects count] > 0) {
                for(NSDictionary *object in objects) {
                    if([object valueForKey:@"value"]) {
                        [results addObject:[object valueForKey:@"value"]];
                    }
                }
            }
            
            if([results count]) {
                NSArray *sorted = [NSArray arrayWithArray:results];
                returnArray = [sorted sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            }
        }];
    }
    
    return returnArray;
}

#pragma mark - Helpers
- (NSString *)medicineTypeHR:(NSInteger)type {
    NSString *typeHR = nil;
    switch(type) {
        case kMedicineTypePills:
            typeHR = NSLocalizedString(@"pills", @"Type/unit of medicine");
            break;
        case kMedicineTypePuffs:
            typeHR = NSLocalizedString(@"puffs", @"Type/unit of medicine");
            break;
        case kMedicineTypeMG:
            typeHR = NSLocalizedString(@"mg", @"Type/unit of medicine");
            break;
        case kMedicineTypeUnits:
            typeHR = NSLocalizedString(@"units", @"Type/unit of medicine");
            break;
    }
    
    return typeHR;
}

@end
