//
//  IMBackupController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 31/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMBackupController : NSObject

// Logic
- (void)backupToDropbox:(void (^)(NSError *))completionCallback;
- (void)restoreFromBackup:(void (^)(NSError *))completionCallback;

@end
