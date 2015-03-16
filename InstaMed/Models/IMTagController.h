//
//  IMTagController.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 18/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMTag.h"
#import "IMEvent.h"

@interface IMTagController : NSObject

+ (id)sharedInstance;

// String Helpers
- (NSRange)rangeOfTagInString:(NSString *)string withCaretLocation:(NSUInteger)caretLocation;

// Regular Expression
+ (NSRegularExpression *)tagRegularExpression;

// Helpers
- (NSArray *)fetchTagsInString:(NSString *)string;
- (NSArray *)fetchAllTags;
- (NSArray *)fetchExistingTagsWithStrings:(NSArray *)strings;
- (void)assignTags:(NSArray *)tags toEvent:(IMEvent *)event;

@end
