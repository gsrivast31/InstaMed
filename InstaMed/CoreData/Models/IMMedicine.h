//
//  IMMedicine.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMEvent.h"

#define kMedicineTypeUnits 0
#define kMedicineTypeMG 1
#define kMedicineTypePills 2
#define kMedicineTypePuffs 3

@interface IMMedicine : IMEvent

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * type;

@end
