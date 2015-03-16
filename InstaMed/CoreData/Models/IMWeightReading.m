//
//  IMWeightReading.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMWeightReading.h"


@implementation IMWeightReading

@dynamic value;

#pragma mark - Transient properties

- (NSString *)humanReadableName {
    return NSLocalizedString(@"Weight Reading", nil);
}

@end
