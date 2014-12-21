//
//  IMEventController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMCommon.h"
#import "IMEvent.h"
#import "IMMedicine.h"
#import "IMMeal.h"
#import "IMActivity.h"
#import "IMReading.h"
#import "IMNote.h"

@class IMAccount;
@interface IMEventController : NSObject

+ (id)sharedInstance;
- (void)setMOC:(NSManagedObjectContext *)aMOC;

// Events
- (void)attemptSmartInputWithExistingEntries:(NSMutableArray *)existingEntries success:(void (^)(IMMedicine*))successBlock failure:(void (^)(void))failureBlock;
- (NSArray *)fetchEventsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)moc;
- (NSDictionary *)statisticsForEvents:(NSArray *)events fromDate:(NSDate *)minDate toDate:(NSDate *)maxDate;
- (NSArray *)fetchKey:(NSString *)key forEventsWithFilterType:(EventFilterType)filterType;

// Helpers
- (NSString *)medicineTypeHR:(NSInteger)type;

@end
