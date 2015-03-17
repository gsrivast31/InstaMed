//
//  IMBGReading.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMBGReading.h"


@implementation IMBGReading

@dynamic mgValue;
@dynamic mmoValue;

#pragma mark - Transient properties
- (NSNumber *)value {
    NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
    NSString *valueKey = (unitSetting == BGTrackingUnitMG) ? @"mgValue" : @"mmoValue";
    
    return (NSNumber *)[self valueForKey:valueKey];
}

- (NSString *)humanReadableName {
    return NSLocalizedString(@"Blood Glucose Reading", nil);
}

@end
