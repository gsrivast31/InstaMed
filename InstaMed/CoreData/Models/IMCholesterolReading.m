//
//  IMCholesterolReading.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMCholesterolReading.h"


@implementation IMCholesterolReading

@dynamic mgValue;
@dynamic mmoValue;

#pragma mark - Transient properties
- (NSNumber *)value {
    NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kChTrackingUnitKey];
    NSString *valueKey = (unitSetting == ChTrackingUnitMG) ? @"mgValue" : @"mmoValue";
    
    return (NSNumber *)[self valueForKey:valueKey];
}

- (NSString *)humanReadableName {
    return NSLocalizedString(@"Cholesterol Reading", nil);
}

@end
