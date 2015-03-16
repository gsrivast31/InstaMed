//
//  IMImage.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 17/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IMReport;

@interface IMImage : NSManagedObject

@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) IMReport *report;

@end
