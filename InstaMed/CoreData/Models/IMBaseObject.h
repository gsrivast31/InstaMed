//
//  IMBaseObject.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IMBaseObject : NSManagedObject

@property (nonatomic, assign) BOOL traversed;
@property (nonatomic, retain) NSDate * createdTimestamp;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSDate * modifiedTimeStamp;
@property (nonatomic, retain) NSString * userGuid;


// Archiving/Unarchiving
- (NSDictionary *)dictionaryRepresentation;
- (void)populateFromDictionaryRepresentation:(NSDictionary*)dict;
+ (IMBaseObject *)createManagedObjectFromDictionaryRepresentation:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context;

// Helpers
- (NSString *)generateUniqueID;

@end
