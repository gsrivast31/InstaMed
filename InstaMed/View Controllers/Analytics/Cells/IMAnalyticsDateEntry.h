//
//  IMAnalyticsDateEntry.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

typedef NS_ENUM(NSInteger, IMAnalyticsDateEntryType){
	IMToday = 0,
    IMLastWeek = 1,
    IMLast2Weeks = 2,
    IMThisMonth = 3,
    IMLastMonth = 4,
    IMLast3Months = 5,
    IMLast6Months = 6,
    IMCustomDate = 7,
    IMCustomRange = 8
};

@interface IMAnalyticsDateEntry : NSObject

@property (nonatomic, assign) IMAnalyticsDateEntryType type;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) NSDate* fromDate;
@property (nonatomic, strong) NSDate* toDate;

- (id)initWithType:(IMAnalyticsDateEntryType)type;
- (NSString*)dateString;

@end
