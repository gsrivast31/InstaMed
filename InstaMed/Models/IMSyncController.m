//
//  IMSyncController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Dropbox/Dropbox.h>
#import "SSKeychain.h"
#import "Reachability.h"

#import "IMAnalytikController.h"
#import "IMSyncController.h"
#import "IMBackupController.h"

@interface IMSyncController ()
{
    __block UIBackgroundTaskIdentifier backgroundTask;
}
@property (nonatomic, strong) NSTimer *syncTimer;

// Helpers
- (BOOL)analytikRequiresSync;

@end

@implementation IMSyncController

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
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf syncInBackground:YES];
        }];
    }
    
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Logic
- (void)syncInBackground:(BOOL)backgroundSync
{
    BOOL analyticRequiresSync = [self analytikRequiresSync];
    BOOL backupRequiresSync = [self backupRequiresSync];
    
    if(analyticRequiresSync || backupRequiresSync)
    {
        UIApplication *application = [UIApplication sharedApplication];
        if(backgroundSync)
        {
            backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }];
        }
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            if(backupRequiresSync)
            {
                dispatch_group_enter(dispatchGroup);
                [self syncBackupWithCompletionHandler:^{
                    dispatch_group_leave(dispatchGroup);
                }];
            }
            if(analyticRequiresSync)
            {
                dispatch_group_enter(dispatchGroup);
                [self syncAnalytikWithCompletionHandler:^{
                    dispatch_group_leave(dispatchGroup);
                }];
            }
        });
        
        dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if(backgroundSync)
            {
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    }
}
- (void)syncBackupWithCompletionHandler:(void (^)(void))completionBlock
{
    IMBackupController *backupController = [[IMBackupController alloc] init];
    [backupController backupToDropbox:^(NSError *error) {
        
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setInteger:timestamp forKey:kLastBackupTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(completionBlock) completionBlock();
    }];
}
- (void)syncAnalytikWithCompletionHandler:(void (^)(void))completionBlock
{
    NSDate *syncFromDate = [[NSDate date] dateBySubtractingDays:90];
    NSNumber *lastSyncTimestamp = [[NSUserDefaults standardUserDefaults] valueForKey:kAnalytikLastSyncTimestampKey];
    if(lastSyncTimestamp)
    {
        syncFromDate = [NSDate dateWithTimeIntervalSince1970:[lastSyncTimestamp integerValue]];
    }
    
    // Check if we actually have anything to sync
    if([[self analytikController] needsToSyncFromDate:syncFromDate])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [[self analytikController] syncFromDate:syncFromDate success:^{
                
                [[NSUserDefaults standardUserDefaults] setInteger:[[NSDate date] timeIntervalSince1970] forKey:kAnalytikLastSyncTimestampKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if(completionBlock) completionBlock();
                
            } failure:^(NSError *error) {
                if(completionBlock) completionBlock();
            }];
            
        });
    }
    else
    {
        if(completionBlock) completionBlock();
    }
}

#pragma mark - Helpers
- (BOOL)analytikRequiresSync
{
    NSDate *syncFromDate = [[NSDate date] dateBySubtractingDays:90];
    NSNumber *lastSyncTimestamp = [[NSUserDefaults standardUserDefaults] valueForKey:kAnalytikLastSyncTimestampKey];
    if(lastSyncTimestamp)
    {
        syncFromDate = [NSDate dateWithTimeIntervalSince1970:[lastSyncTimestamp integerValue]];
    }
    
    return [[self analytikController] needsToSyncFromDate:syncFromDate];
}
- (BOOL)backupRequiresSync
{
    if([[DBAccountManager sharedManager] linkedAccount])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults boolForKey:kAutomaticBackupEnabledKey])
        {
            NSInteger frequency = [defaults integerForKey:kAutomaticBackupFrequencyKey];
            NSInteger lastBackupTimestamp = [defaults integerForKey:kLastBackupTimestamp];
            NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
            
            if((currentTimestamp-lastBackupTimestamp) >= frequency)
            {
                BOOL requiresWifi = ![defaults boolForKey:kWWANAutomaticBackupEnabledKey];
                Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
                if(requiresWifi && ![reachability isReachableViaWiFi])
                {
                    return NO;
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Accessors
- (IMAnalytikController *)analytikController
{
    static dispatch_once_t pred = 0;
    __strong static IMAnalytikController* _analytikController = nil;
    dispatch_once(&pred, ^{
        _analytikController = [[IMAnalytikController alloc] init];
    });
    
    return _analytikController;
}

@end
