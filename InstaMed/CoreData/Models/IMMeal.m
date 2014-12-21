//
//  IMMeal.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMMeal.h"


@implementation IMMeal

@dynamic grams;
@dynamic type;

#pragma mark - Transient properties
- (NSString *)humanReadableName
{
    return NSLocalizedString(@"Food", nil);
}

@end
