//
//  IMCoreDataController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMCoreDataController : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;

// Logic
- (void)saveContext;

// Helpers
- (NSManagedObjectContext *)newPrivateContext;

@end
