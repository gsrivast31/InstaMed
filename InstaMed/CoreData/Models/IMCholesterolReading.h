//
//  IMCholesterolReading.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMEvent.h"

@interface IMCholesterolReading : IMEvent

@property (nonatomic, retain) NSNumber * mgValue;
@property (nonatomic, retain) NSNumber * mmoValue;

- (NSString *)humanReadableName;
- (NSNumber *)value;

@end
