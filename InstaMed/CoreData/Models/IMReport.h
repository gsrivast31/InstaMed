//
//  IMReport.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 17/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IMBaseObject.h"

@class IMImage;

NS_ENUM(int16_t, IMReportType) {
    IMReportPhysician = 0,
    IMReportLabResults = 1,
    IMReportSpecialist = 2,
    IMReportDrugsAndPrescriptions = 3,
    IMReportHospitalAdmissions = 4,
    IMReportMedicalHistory = 5,
    IMReportOther = 6,
    IMReportAll = 7
};

@interface IMReport : IMBaseObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * doctorName;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSSet *images;
@end

@interface IMReport (CoreDataGeneratedAccessors)

- (void)addImagesObject:(IMImage *)value;
- (void)removeImagesObject:(IMImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
