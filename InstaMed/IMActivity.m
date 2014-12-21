//
//  IMActivity.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMActivity.h"


@implementation IMActivity

@dynamic minutes;

#pragma mark - Transient properties
- (NSString *)humanReadableName
{
    return NSLocalizedString(@"Activity", nil);
}

@end
