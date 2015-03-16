//
//  IMBPReading.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMBPReading.h"


@implementation IMBPReading

@dynamic lowValue;
@dynamic highValue;

#pragma mark - Transient properties
- (NSString *)humanReadableName {
    return NSLocalizedString(@"Blood Pressure Reading", nil);
}

@end
