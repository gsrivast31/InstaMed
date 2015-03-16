//
//  IMEvent.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMBaseObject.h"

@class IMTag;

@interface IMEvent : IMBaseObject

@property (nonatomic, retain) NSString * externalGUID;
@property (nonatomic, retain) NSString * externalSource;
@property (nonatomic, retain) NSNumber * filterType;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSString * sectionIdentifier;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSDate *primitiveTimestamp;
@property (nonatomic, retain) NSString *primitiveSectionIdentifier;

// Transient properties
- (NSString *)humanReadableName;

@end

@interface IMEvent (CoreDataGeneratedAccessors)

- (void)addTagsObject:(IMTag *)value;
- (void)removeTagsObject:(IMTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
