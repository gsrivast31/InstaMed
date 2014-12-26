//
//  IMBPReading.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMEvent.h"


@interface IMBPReading : IMEvent

@property (nonatomic, retain) NSNumber * lowValue;
@property (nonatomic, retain) NSNumber * highValue;

- (NSString *)humanReadableName;

@end
