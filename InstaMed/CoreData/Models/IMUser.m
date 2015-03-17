//
//  IMUser.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMUser.h"
#import "IMDisease.h"


@implementation IMUser

@dynamic bloodgroup;
@dynamic age;
@dynamic email;
@dynamic gender;
@dynamic height;
@dynamic name;
@dynamic profilePhoto;
@dynamic relationship;
@dynamic weight;
@dynamic trackingDiabetes;
@dynamic trackingHyperTension;
@dynamic trackingCholesterol;
@dynamic trackingWeight;
@dynamic diseases;
@dynamic guid;

#pragma mark Setup
- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.guid = [self generateUniqueID];
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    //TODO : Delete all related events/reminders/reports.

}

#pragma mark - Helpers
- (NSString *)generateUniqueID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *str = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return str;
}


@end
