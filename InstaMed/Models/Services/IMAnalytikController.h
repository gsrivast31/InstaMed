//
//  IMAnalytikController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMAnalytikController : NSObject

// Logic
- (void)authorizeWithCredentials:(NSDictionary *)credentials
                         success:(void (^)(void))successBlock
                         failure:(void (^)(NSError *))failureBlock;
- (void)syncFromDate:(NSDate *)fromDate
             success:(void (^)(void))successBlock
             failure:(void (^)(NSError *))failureBlock;
- (void)destroyCredentials;

// Accessors
- (BOOL)needsToSyncFromDate:(NSDate *)date;

// Helpers
- (NSDictionary *)activeAccount;

@end
