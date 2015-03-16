//
//  IMTag.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMBaseObject.h"

@class IMEvent;

@interface IMTag : IMBaseObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameLC;
@property (nonatomic, retain) NSSet *events;
@end

@interface IMTag (CoreDataGeneratedAccessors)

- (void)addEventsObject:(IMEvent *)value;
- (void)removeEventsObject:(IMEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
