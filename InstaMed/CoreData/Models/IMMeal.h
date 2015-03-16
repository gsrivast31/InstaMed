//
//  IMMeal.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMEvent.h"


@interface IMMeal : IMEvent

@property (nonatomic, retain) NSNumber * grams;
@property (nonatomic, retain) NSNumber * type;

@end
