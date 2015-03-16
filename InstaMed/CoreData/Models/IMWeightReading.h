//
//  IMWeightReading.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMEvent.h"

@interface IMWeightReading : IMEvent

@property (nonatomic, retain) NSNumber * value;

- (NSString *)humanReadableName;

@end
