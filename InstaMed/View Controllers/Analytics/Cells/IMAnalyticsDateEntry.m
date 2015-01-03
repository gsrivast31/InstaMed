//
//  IMAnalyticsDateEntry.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsDateEntry.h"
#import "IMAnalyticsConstants.h"

@implementation IMAnalyticsDateEntry

#pragma mark - Alloc/Init

- (id)initWithType:(IMAnalyticsDateEntryType)type {
    self = [super init];
    if (self) {
        self.type = type;
        if (type == IMToday) {
            self.title = @"Today";
            self.fromDate = [[NSDate date] dateAtStartOfDay];
            self.toDate = [[NSDate date] dateAtEndOfDay];
        } else if (type == IMLastWeek) {
            self.title = @"Last 7 Days";
            self.fromDate = [[[[NSDate date] dateAtStartOfDay] dateBySubtractingDays:6] dateAtEndOfDay];
            self.toDate = [[NSDate date] dateAtEndOfDay];
        } else if (type == IMLast2Weeks) {
            self.title = @"Last 14 Days";
            self.fromDate = [[[[NSDate date] dateAtStartOfDay] dateBySubtractingDays:13] dateAtEndOfDay];
            self.toDate = [[NSDate date] dateAtEndOfDay];
        } else if (type == IMThisMonth) {
            self.title = @"This Month";
            self.fromDate = [[NSDate date] dateAtStartOfMonth];
            self.toDate = [[NSDate date] dateAtEndOfDay];
        } else if (type == IMLastMonth) {
            self.title = @"Last Month";
            self.toDate = [[NSDate date] dateAtStartOfMonth];
            NSDateComponents *comp = [[NSDateComponents alloc] init];
            [comp setMonth:-1];
            self.toDate = [[[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self.toDate options:0] dateAtEndOfMonth];
            self.fromDate = [self.toDate dateAtStartOfMonth];
        } else if (type == IMLast3Months) {
            self.title = @"Last 3 Months";
            self.toDate = [[NSDate date] dateAtStartOfMonth];
            NSDateComponents *comp = [[NSDateComponents alloc] init];
            [comp setMonth:-1];
            self.toDate = [[[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self.toDate options:0] dateAtEndOfMonth];
            [comp setMonth:-2];
            self.fromDate = [[[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self.toDate options:0] dateAtStartOfMonth];
        } else if (type == IMLast6Months) {
            self.title = @"Last 6 Months";
            self.toDate = [[NSDate date] dateAtStartOfMonth];
            NSDateComponents *comp = [[NSDateComponents alloc] init];
            [comp setMonth:-1];
            self.toDate = [[[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self.toDate options:0] dateAtEndOfMonth];
            [comp setMonth:-5];
            self.fromDate = [[[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self.toDate options:0] dateAtStartOfMonth];
        } else if (type == IMCustomDate) {
            self.title = @"Custom Date";
            self.fromDate = self.toDate = nil;
        } else if (type == IMCustomRange) {
            self.title = @"Custom Range";
            self.fromDate = self.toDate = nil;
        }
    }
    return self;
}

#pragma mark Helpers
- (NSString*)fromDateString {
    NSString* date = nil;
    if (self.fromDate) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        date = [dateFormatter stringFromDate:self.fromDate];
    }
    return date;
}

- (NSString*)toDateString {
    NSString* date = nil;
    if (self.toDate) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        date = [dateFormatter stringFromDate:self.toDate];
    }
    return date;
}

- (NSString*)dateString {
    NSString* fromString = [self fromDateString];
    NSString* toString = [self toDateString];
    if (fromString && toString) {
        if ([fromString isEqualToString:toString]) {
            return [NSString stringWithFormat:@"%@", fromString];
        } else {
            return [NSString stringWithFormat:@"%@ - %@", fromString, toString];
        }
    } else {
        return @"";
    }
}
@end
