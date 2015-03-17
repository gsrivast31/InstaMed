//
//  IMTag.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMTag.h"
#import "IMEvent.h"


@implementation IMTag

@dynamic name;
@dynamic nameLC;
@dynamic events;

#pragma mark - Setters
- (void)setName:(NSString *)aName
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:aName forKey:@"name"];
    [self didChangeValueForKey:@"name"];
    
    [self willChangeValueForKey:@"nameLC"];
    [self setPrimitiveValue:[aName lowercaseString] forKey:@"nameLC"];
    [self didChangeValueForKey:@"nameLC"];
}

@end
