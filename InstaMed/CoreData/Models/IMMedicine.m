//
//  IMMedicine.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMMedicine.h"


@implementation IMMedicine

@dynamic amount;
@dynamic type;

#pragma mark - Transient properties
- (NSString *)humanReadableName
{
    return NSLocalizedString(@"Medication", nil);
}

@end
