//
//  IMAppDelegate.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAppDelegate.h"

#import <Dropbox/Dropbox.h>
#import <ShinobiCharts/ShinobiChart.h>
#import <UAAppReviewManager/UAAppReviewManager.h>
#import "GAI.h"

#import "IMHelper.h"
#import "IMAppDelegate.h"
#import "IMJournalViewController.h"
#import "IMJournalTableViewController.h"
#import "IMSideMenuViewController.h"

#import "IMReminderController.h"
#import "IMLocationController.h"
#import "IMEventController.h"

@interface IMAppDelegate ()

@end

@implementation IMAppDelegate

#pragma mark - Setup
+ (IMAppDelegate *)sharedAppDelegate {
    return (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialise the Google Analytics API
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingID];
    
    // Initialise Appirater
    [UAAppReviewManager setAppID:@"634983291"];
    [UAAppReviewManager setDaysUntilPrompt:2];
    [UAAppReviewManager setUsesUntilPrompt:5];
    [UAAppReviewManager setSignificantEventsUntilPrompt:-1];
    [UAAppReviewManager setDaysBeforeReminding:3];
    [UAAppReviewManager setReviewMessage:NSLocalizedString(@"If you find InstaMed useful you can help support further development by leaving a review on the App Store. It'll only take a minute!", nil)];
    
    // Is this a first run experience?
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasRunBeforeKey]) {
        // Dump any existing local notifications (handy when the application has been deleted and re-installed,
        // as iOS likes to keep local notifications around for 24 hours)
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasRunBeforeKey];
    }
    
    [self setupDefaultConfigurationValues];
    [self setupStyling];
    
    // Wake up singletons
    [IMCoreDataStack defaultStack];
    [IMReminderController sharedInstance];
    [self setBackupController:[[IMBackupController alloc] init]];
    
    // Setup our backup controller
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = kDefaultTintColor;
    
    // Delay launch on non-essential classes
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf setupDropbox];
            
            // Call various singletons
            [IMLocationController sharedInstance];
        });
    });
    
    UINavigationController* navController = (UINavigationController*)self.window.rootViewController;
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSString *currentProfile = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
    if (currentProfile && ![currentProfile isEqualToString:@""]) {
        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"rootController"] animated:NO];
    } else {
        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"pageController"] animated:NO];
    }
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    
    // Let UAAppReviewManager know our application has launched
    [UAAppReviewManager showPromptIfNecessary];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[IMCoreDataStack defaultStack] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationResumed" object:nil];
    
    // Let UAAppReviewManager know our application has entered the foreground
    [UAAppReviewManager showPromptIfNecessary];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Delete any expired date-based notifications
    [[IMReminderController sharedInstance] deleteExpiredReminders];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    // Is this Dropbox?
    if([source isEqualToString:@"com.getdropbox.Dropbox"]) {
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        if (account) {
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
            
            // Post a notification so that we can determine when linking occurs
            [[NSNotificationCenter defaultCenter] postNotificationName:kDropboxLinkNotification object:account];
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Logic
- (void)setupDropbox {
    // Ditch out if we haven't been provided credentials
    if(!kDropboxAppKey || !kDropboxSecret || ![kDropboxAppKey length] || ![kDropboxSecret length]) return;
    
    DBAccountManager *accountMgr = [[DBAccountManager alloc] initWithAppKey:kDropboxAppKey secret:kDropboxSecret];
    [DBAccountManager setSharedManager:accountMgr];
    DBAccount *account = accountMgr.linkedAccount;
    
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
}

- (void)setupDefaultConfigurationValues
{
    // Try to determine the users blood sugar unit based on their locale
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              kBGTrackingUnitKey: [NSNumber numberWithInt:([countryCode isEqualToString:@"US"]) ? BGTrackingUnitMG : BGTrackingUnitMMO],
                                                              kMinHealthyBGKey: @4,
                                                              kMaxHealthyBGKey: @7,
                                                              
                                                              kChTrackingUnitKey: [NSNumber numberWithInt:([countryCode isEqualToString:@"US"]) ? ChTrackingUnitMG : ChTrackingUnitMMO],
                                                              kMinHealthyChKey: @6,
                                                              kMaxHealthyChKey: @11,
                                                              
                                                              kMinHealthyBPKey: @80,
                                                              kMaxHealthyBPKey: @120,
                                                              
                                                              kTargetWeightKey: @60,
                                                              
                                                              kCurrentProfileTrackingBPKey: @NO,
                                                              kCurrentProfileTrackingCholesterolKey: @NO,
                                                              kCurrentProfileTrackingDiabetesKey: @NO,
                                                              kCurrentProfileTrackingWeightKey: @NO,
                                                              
                                                              kUseSmartInputKey: @YES,
                                                              kShowInlineImages: @YES,
                                                              kFilterSearchResultsKey: @YES,
                                                              kAutomaticallyGeotagEvents: @YES }];
    
    [self setDefaultProfile];
}

- (void)setDefaultProfile {
/*    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc)
    {
        [moc performBlockAndWait:^{
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMUser" inManagedObjectContext:moc];
            [request setEntity:entity];
            [request setResultType:NSManagedObjectResultType];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationship == Self", ];
            [request setPredicate:predicate];
            
            // Execute the fetch.
            NSError *error = nil;
            NSMutableArray *results = [NSMutableArray array];
            NSArray *objects = [moc executeFetchRequest:request error:&error];
            if (objects != nil && [objects count] > 0)
            {
                for(NSDictionary *object in objects)
                {
                    if([object valueForKey:@"value"])
                    {
                        [results addObject:[object valueForKey:@"value"]];
                    }
                }
            }
            
            if([results count])
            {
                NSArray *sorted = [NSArray arrayWithArray:results];
                returnArray = [sorted sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            }
        }];
    }*/
    
}

- (void)setupStyling
{
    NSDictionary *attributes = nil;
    
    UIColor *defaultBarTintColor = kDefaultBarTintColor;
    [[UINavigationBar appearance] setBarTintColor:defaultBarTintColor];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[IMFont standardDemiBoldFontWithSize:17.0f]}];
    
    // UISwitch
    [[UISwitch appearance] setOnTintColor:[UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
    
    // UISegmentedControl
    attributes = @{
                   NSFontAttributeName: [IMFont standardDemiBoldFontWithSize:13.0f],
                   NSForegroundColorAttributeName: [UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]
                   };
    [[UISegmentedControl appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
    
    // Charts
    [ShinobiCharts setTheme:[SChartiOS7Theme new]];
}

#pragma mark - Location services
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[IMReminderController sharedInstance] didReceiveLocalNotification:notification];
}

@end
