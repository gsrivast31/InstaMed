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
+ (NSNumber *)formatBGReadingWithValue:(NSNumber *)value inUnit:(NSInteger)unit;
+ (NSDateFormatter *)shortTimeFormatter;
+ (NSDateFormatter *)hhmmTimeFormatter;
+ (NSNumberFormatter *)glucoseNumberFormatter;
+ (NSNumberFormatter *)standardNumberFormatter;

// Converters
+ (NSNumber *)convertBGValue:(NSNumber *)value fromUnit:(NSInteger)fromUnit toUnit:(NSInteger)toUnit;

// Helpers
+ (NSInteger)userBGUnit;
+ (BOOL)isBGLevelSafe:(double)value;

@end
