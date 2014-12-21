//
//  IMSyncController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMAnalytikController.h"

@interface IMSyncController : NSObject

+ (id)sharedInstance;

// Logic
- (void)syncInBackground:(BOOL)backgroundSync;
- (void)syncAnalytikWithCompletionHandler:(void (^)(void))completionBlock;
- (void)syncBackupWithCompletionHandler:(void (^)(void))completionBlock;

// Accessors
- (IMAnalytikController *)analytikController;

@end
