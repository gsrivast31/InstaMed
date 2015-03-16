//
//  IMUser.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IMDisease;

NS_ENUM(int16_t, IMGender) {
    IMUserMale = 0,
    IMUserFemale = 1,
    IMUserOther = 2
};

NS_ENUM(int16_t, IMTrackedDisease) {
    IMDiabetes = 0,
    IMHyperTension = 1
};

@interface IMUser : NSManagedObject

@property (nonatomic, retain) NSString * bloodgroup;
@property (nonatomic) int16_t age;
@property (nonatomic, retain) NSString * email;
@property (nonatomic) int16_t gender;
@property (nonatomic) int16_t height;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * profilePhoto;
@property (nonatomic, retain) NSString * relationship;
@property (nonatomic) int16_t weight;
@property (nonatomic) BOOL trackingDiabetes;
@property (nonatomic) BOOL trackingHyperTension;
@property (nonatomic) BOOL trackingCholesterol;
@property (nonatomic) BOOL trackingWeight;
@property (nonatomic, retain) NSSet *diseases;
@property (nonatomic, retain) NSString * guid;
@end

@interface IMUser (CoreDataGeneratedAccessors)

- (void)addDiseasesObject:(IMDisease *)value;
- (void)removeDiseasesObject:(IMDisease *)value;
- (void)addDiseases:(NSSet *)values;
- (void)removeDiseases:(NSSet *)values;

@end
