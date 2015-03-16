//
//  NSString+Extension.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

// Transforms
- (NSString *)escapedForCSV;
- (NSArray *)characterArray;

// Levenshtein
- (NSUInteger)levenshteinDistanceToString:(NSString *)string;

@end
