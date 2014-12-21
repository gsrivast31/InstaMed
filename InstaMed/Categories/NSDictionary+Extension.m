//
//  NSDictionary+Extension.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//


#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

- (NSString *)jsonStringWithPrettyPrint:(BOOL)prettyPrint
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if(!jsonData)
    {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return nil;
    }
    else
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end
