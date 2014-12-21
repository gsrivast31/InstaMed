//
//  IMCoreDataController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMCoreDataController.h"

@interface IMCoreDataController ()
{
    UIAlertView *cloudContentCorruptedAlert;
    UIAlertView *cloudContentHealingAlert;
    UIAlertView *handleCloudContentWarningAlert;
    UIAlertView *handleLocalStoreAlert;
    
    __block UIAlertView *iCloudEnabledAlertView;
    __block UIAlertView *iCloudDisabledAlertView;
}
@property (copy, nonatomic) void(^iCloudConfirmationBlock)(BOOL);

// Helpers
- (NSURL *)persistentStoreURL;
- (NSURL *)applicationDocumentsDirectory;

@end

@implementation IMCoreDataController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        [self managedObjectContext];
        
        /*
        self.ubiquityStoreManager = [[UbiquityStoreManager alloc] initStoreNamed:@"InstaMed"
                                                          withManagedObjectModel:nil
                                                                   localStoreURL:[self persistentStoreURL]
                                                             containerIdentifier:nil
                                                          additionalStoreOptions:nil
                                                                        delegate:self];
         */
    }
    
    return self;
}

#pragma mark - Logic
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"InstaMed" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self persistentStoreURL];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
 
#pragma mark - Helpers
- (NSManagedObjectContext *)newPrivateContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return context;
}
- (NSURL *)persistentStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"InstaMed.sqlite"];
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
