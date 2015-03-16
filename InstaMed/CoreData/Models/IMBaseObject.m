//
//  IMBaseObject.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMBaseObject.h"


@implementation IMBaseObject

@synthesize traversed;
@dynamic createdTimestamp;
@dynamic guid;
@dynamic userGuid;
@dynamic modifiedTimeStamp;

#pragma mark - Setup
- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.guid = [self generateUniqueID];
    self.createdTimestamp = [NSDate date];
    
    NSString* userGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
    self.userGuid = userGuid;
}

#pragma mark - Logic
- (void)willSave {
    [super willSave];
    
    if([self isUpdated]) {
        [self setPrimitiveValue:[NSDate date] forKey:@"modifiedTimestamp"];
    }
}

#pragma mark - Archiver
- (NSDictionary *)dictionaryRepresentation {
    self.traversed = YES;
    
    NSArray *attributes = [[[self entity] attributesByName] allKeys];
    NSArray *relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + [relationships count] + 1];
    
    [dict setObject:[[self class] description]forKey:@"class"];
    
    for(NSString *attr in attributes) {
        NSObject *value = [self valueForKey:attr];
        
        if(value != nil) {
            [dict setObject:value forKey:attr];
        }
    }
    
    for(NSString *relationship in relationships) {
        NSObject *value = [self valueForKey:relationship];
        
        if([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
            
            // Our set holds a collection of dictionaries
            NSMutableSet* dictSet = [NSMutableSet setWithCapacity:[relatedObjects count]];
            for(IMBaseObject *relatedObject in relatedObjects) {
                if (!relatedObject.traversed) {
                    [dictSet addObject:[relatedObject dictionaryRepresentation]];
                }
            }
            
            [dict setObject:dictSet forKey:relationship];
        } else if ([value isKindOfClass:[IMBaseObject class]]) {
            // To-one relationship
            IMBaseObject* relatedObject = (IMBaseObject *)value;
            
            if (!relatedObject.traversed) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject dictionaryRepresentation] forKey:relationship];
            }
        }
    }
    
    return dict;
}

- (void)populateFromDictionaryRepresentation:(NSDictionary*)dict {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(NSString *key in dict) {
        if([key isEqualToString:@"class"]) continue;
        
        NSObject *value = [dict objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            IMBaseObject *relatedObject = [IMBaseObject createManagedObjectFromDictionaryRepresentation:(NSDictionary *)value inContext:context];
            [self setValue:relatedObject forKey:key];
        } else if ([value isKindOfClass:[NSSet class]]) {
            // This is a to-many relationship
            NSSet *relatedObjectDictionaries = (NSSet*) value;
            
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet *relatedObjects = [self mutableSetValueForKey:key];
            
            for (NSDictionary *relatedObjectDict in relatedObjectDictionaries) {
                IMBaseObject *relatedObject = [IMBaseObject createManagedObjectFromDictionaryRepresentation:relatedObjectDict inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        } else if (value != nil) {
            // This is an attribute
            [self setValue:value forKey:key];
        }
    }
}

+ (IMBaseObject *)createManagedObjectFromDictionaryRepresentation:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    NSString *guid = [dict objectForKey:@"guid"];
    NSString *class = [dict objectForKey:@"class"];
    NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];

    IMBaseObject *object = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMBaseObject" inManagedObjectContext:context];
    if(entity) {
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid = %@ && userGuid = %@", guid, currentUserGuid];
        [request setPredicate:predicate];
        
        @try {
            // Execute the fetch.
            NSError *error = nil;
            NSArray *objects = [context executeFetchRequest:request error:&error];
            if (objects != nil && [objects count] > 0) {
                object = [objects objectAtIndex:0];
            } else {
                object = (IMBaseObject *)[NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:context];
            }
            
            [object populateFromDictionaryRepresentation:dict];
        }
        @catch (NSException *exception) {
            // STUB
        }
        @finally {
            // STUB
        }
    }
    
    return object;
}

#pragma mark - Helpers
- (NSString *)generateUniqueID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *str = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return str;
}

@end
