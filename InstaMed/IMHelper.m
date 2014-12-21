//
//  IMHelper.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//


#import "IMHelper.h"

@implementation IMHelper

#pragma mark - Formatter methods

+ (NSString *)formatMinutes:(double)minutes
{
    int hours = minutes/60;
    int mins = (int)minutes%60;
    
    return [NSString stringWithFormat:@"%02d:%02d", hours, mins];
}

+ (NSNumber *)formatBGReadingWithValue:(NSNumber *)value inUnit:(NSInteger)units
{
    if(units == BGTrackingUnitMG)
    {
        value = [NSNumber numberWithInteger:[value integerValue]];
    }
    
    return value;
}

+ (NSNumberFormatter *)standardNumberFormatter
{
    static dispatch_once_t pred;
    static NSNumberFormatter *standardFormatter = nil;
    dispatch_once(&pred, ^{
        standardFormatter = [[NSNumberFormatter alloc] init];
    });
    [standardFormatter setAlwaysShowsDecimalSeparator:NO];
    [standardFormatter setMaximumFractionDigits:4];
    
    return standardFormatter;
}

+ (NSNumberFormatter *)glucoseNumberFormatter
{
    static dispatch_once_t pred;
    static NSNumberFormatter *glucoseFormatter = nil;
    dispatch_once(&pred, ^{
        glucoseFormatter = [[NSNumberFormatter alloc] init];
    });
    [glucoseFormatter setAlwaysShowsDecimalSeparator:NO];
    [glucoseFormatter setMaximumFractionDigits:[IMHelper userBGUnit] == BGTrackingUnitMG ? 0 : 2];
    
    return glucoseFormatter;
}

+ (NSDateFormatter *)shortTimeFormatter
{
    static dispatch_once_t pred;
    static NSDateFormatter *shortTimeFormatter = nil;
    dispatch_once(&pred, ^{
        shortTimeFormatter = [[NSDateFormatter alloc] init];
        [shortTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    
    return shortTimeFormatter;
}

+ (NSDateFormatter *)hhmmTimeFormatter
{
    static dispatch_once_t pred;
    static NSDateFormatter *shortTimeFormatter = nil;
    dispatch_once(&pred, ^{
        shortTimeFormatter = [[NSDateFormatter alloc] init];
        [shortTimeFormatter setDateFormat:@"HH:mm"];
    });
    
    return shortTimeFormatter;
}

#pragma mark - Converts
+ (NSNumber *)convertBGValue:(NSNumber *)value fromUnit:(NSInteger)fromUnit toUnit:(NSInteger)toUnit
{
    // NSInteger userUnit = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
    double convertedValue = [value doubleValue];
    
    if(fromUnit == BGTrackingUnitMG && toUnit == BGTrackingUnitMMO)
    {
        convertedValue *= 0.0555;
    }
    else if(fromUnit == BGTrackingUnitMMO && toUnit == BGTrackingUnitMG)
    {
        convertedValue *= 18.0182;
    }
    
    return [IMHelper formatBGReadingWithValue:[NSNumber numberWithDouble:convertedValue] inUnit:toUnit];
}

#pragma mark - Helpers
+ (NSInteger)userBGUnit
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
}
+ (BOOL)isBGLevelSafe:(double)value
{
    NSInteger userUnit = [IMHelper userBGUnit];
    NSNumber *healthyRangeMin = [IMHelper convertBGValue:[[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyBGKey] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
    NSNumber *healthyRangeMax = [IMHelper convertBGValue:[[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyBGKey] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
    
    if(value >= [healthyRangeMin doubleValue] && value <= [healthyRangeMax doubleValue])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
