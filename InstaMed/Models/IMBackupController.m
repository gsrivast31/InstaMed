//
//  IMBackupController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 31/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Dropbox/Dropbox.h>
#import "IMBackupController.h"
#import "IMEventController.h"
#import "IMAppDelegate.h"

@interface IMBackupController ()
@end

@implementation IMBackupController

#pragma mark - Logic
- (void)backupToDropbox:(void (^)(NSError *))completionCallback
{
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc)
    {
        NSManagedObjectContext *childMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        childMOC.parentContext = moc;
        
        [childMOC performBlock:^{
            
            NSError *error = nil;
            NSMutableArray *representations = [NSMutableArray array];
            
            @autoreleasepool {
                NSArray *events = [[IMEventController sharedInstance] fetchEventsWithPredicate:nil sortDescriptors:nil inContext:childMOC];
                if(events)
                {
                    for(IMEvent *event in events)
                    {
                        NSDictionary *representation = [event dictionaryRepresentation];
                        [representations addObject:representation];
                        
                        // Re-fault this object to conserve on memory
                        [childMOC refreshObject:event mergeChanges:NO];
                    }
                }
            }
            
            if([representations count])
            {
                NSDictionary *archive = @{@"metadata": @{@"version": @1}, @"objects": representations};
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:archive];
                
                if([[DBFilesystem sharedFilesystem] completedFirstSync])
                {
                    DBPath *newPath = [[DBPath root] childPath:[NSString stringWithFormat:@"backup.dtk"]];
                    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:newPath error:nil];
                    if(!file)
                    {
                        file = [[DBFilesystem sharedFilesystem] createFile:newPath error:&error];
                    }
                    
                    if(file && !error)
                    {
                        [file writeData:data error:&error];
                        [file close];
                    }
                }
                else
                {
                    error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Dropbox is currently performing a sync operation"}];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionCallback(error);
            });
        }];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"The underlying MOC is unavailable"}];
        completionCallback(error);
    }
}
- (void)restoreFromBackup:(void (^)(NSError *))completionCallback
{
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc)
    {
        NSManagedObjectContext *childMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        childMOC.parentContext = moc;
        
        [childMOC performBlock:^{
            NSError *error = nil;
            DBPath *path = [[DBPath root] childPath:[NSString stringWithFormat:@"backup.dtk"]];
            DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&error];
            
            if(!error && file)
            {
                NSData *data = [file readData:&error];
                if(!error && data)
                {
                    @try {
                        
                        NSDictionary *archive = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
                        
                        for(NSDictionary *representation in archive[@"objects"])
                        {
                            [IMBaseObject createManagedObjectFromDictionaryRepresentation:representation inContext:childMOC];
                        }
                        [file close];
                        
                        [childMOC save:&error];
                        
                    }
                    @catch (NSException *exception) {
                        
                    }
                }
                else
                {
                    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                    [errorInfo setValue:@"Failed to locate backup file" forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionCallback(error);
            });
        }];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"The underlying MOC is unavailable"}];
        completionCallback(error);
    }
}

@end
