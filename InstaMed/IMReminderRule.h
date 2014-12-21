//
//  IMReminderRule.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMBaseObject.h"


@interface IMReminderRule : IMBaseObject

@property (nonatomic, retain) NSNumber * intervalAmount;
@property (nonatomic, retain) NSNumber * intervalType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * predicate;

@end
