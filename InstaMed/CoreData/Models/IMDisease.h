//
//  IMDisease.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 13/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IMUser;

@interface IMDisease : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) IMUser *user;

@end
