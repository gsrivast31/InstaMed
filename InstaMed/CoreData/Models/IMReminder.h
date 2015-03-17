//
//  IMReminder.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMBaseObject.h"


@interface IMReminder : IMBaseObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * days;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * trigger;
@property (nonatomic, retain) NSNumber * type;

@end
