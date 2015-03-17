//
//  IMEvent.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEvent.h"
#import "IMTag.h"
#import "IMMediaController.h"

@implementation IMEvent

@dynamic externalGUID;
@dynamic externalSource;
@dynamic filterType;
@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic notes;
@dynamic photoPath;
@dynamic sectionIdentifier;
@dynamic timestamp;
@dynamic tags;
@dynamic primitiveSectionIdentifier;
@dynamic primitiveTimestamp;

#pragma mark - Logic
- (void)willSave {
    [super willSave];
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    
    // Remove any media
    if(self.photoPath) {
        [[IMMediaController sharedInstance] deleteImageWithFilename:self.photoPath success:nil failure:nil];
        self.photoPath = nil;
    }
    
    // Remove any tags
    for (IMTag *tag in self.tags) {
        if(tag.events.count <= 1) {
            [self.managedObjectContext deleteObject:tag];
        }
    }
}

#pragma mark - Transient properties
- (NSString *)sectionIdentifier {
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp) {
        tmp = [NSString stringWithFormat:@"%f", [[self.timestamp dateWithoutTime] timeIntervalSince1970]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    
    return tmp;
}

- (NSString *)humanReadableName {
    return @"";
}

#pragma mark - Time stamp setter
- (void)setTimestamp:(NSDate *)newDate {
    [self willChangeValueForKey:@"timestamp"];
    [self setPrimitiveTimestamp:newDate];
    [self didChangeValueForKey:@"timestamp"];
    
    [self setPrimitiveSectionIdentifier:nil];
}

#pragma mark - Key path dependencies
+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier {
    return [NSSet setWithObject:@"timestamp"];
}

@end
