//
//  IMHelper.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMHelper : NSObject

// Formatters
+ (NSString *)formatMinutes:(double)minutes;
+ (NSDateFormatter *)shortTimeFormatter;
+ (NSDateFormatter *)hhmmTimeFormatter;
+ (NSNumberFormatter *)glucoseNumberFormatter;
+ (NSNumberFormatter *)cholesterolNumberFormatter;
+ (NSNumberFormatter *)standardNumberFormatter;

// Converters
+ (NSNumber *)convertBGValue:(NSNumber *)value fromUnit:(NSInteger)fromUnit toUnit:(NSInteger)toUnit;
+ (NSNumber *)convertCholesterolValue:(NSNumber *)value fromUnit:(NSInteger)fromUnit toUnit:(NSInteger)toUnit;

// Helpers
+ (NSInteger)userBGUnit;
+ (BOOL)isBGLevelSafe:(double)value;
+ (NSInteger)userChUnit;
+ (BOOL)isCholesterolLevelSafe:(double)value;
+ (BOOL)isBPLevelSafeWithHigh:(uint)high andLow:(uint)low;

+ (NSInteger)totalReadingsCount;
+ (BOOL)includeGlucoseReadings;
+ (BOOL)includeCholesterolReadings;
+ (BOOL)includeBPReadings;
+ (BOOL)includeWeightReadings;

@end
