//
//  IMAppDelegate.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 12/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAppDelegate.h"

#import <UAAppReviewManager/UAAppReviewManager.h>

#import "IMHelper.h"
#import "IMAppDelegate.h"
#import "IMJournalViewController.h"
#import "IMSideMenuViewController.h"

#import "IMReminderController.h"
#import "IMLocationController.h"
#import "IMEventController.h"
#import "IMIntroViewController.h"

@interface IMAppDelegate ()

@end

@implementation IMAppDelegate

#pragma mark - Setup
+ (IMAppDelegate *)sharedAppDelegate {
    return (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialise Appirater
    [UAAppReviewManager setAppID:@"958303692"];
    [UAAppReviewManager setDaysUntilPrompt:2];
    [UAAppReviewManager setUsesUntilPrompt:5];
    [UAAppReviewManager setSignificantEventsUntilPrompt:-1];
    [UAAppReviewManager setDaysBeforeReminding:3];
    [UAAppReviewManager setReviewMessage:NSLocalizedString(@"If you find HealthMemoir useful you can help support further development by leaving a review on the App Store. It'll only take a minute!", nil)];
    
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
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    [IMReminderController sharedInstance];
    
    // Setup our backup controller
    self.window.tintColor = kDefaultTintColor;
    
    // Delay launch on non-essential classes
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
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
        [navController pushViewController:[[IMIntroViewController alloc] init] animated:NO];
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
    return NO;
}

#pragma mark - Logic
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
    
}

- (void)setupStyling
{
    NSDictionary *attributes = nil;
    
    UIColor *defaultBarTintColor = kDefaultBarTintColor;
    [[UINavigationBar appearance] setBarTintColor:defaultBarTintColor];
    UIColor *defaultTintColor = kDefaultTintColor;
    [[UINavigationBar appearance] setTintColor:defaultTintColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName:[IMFont standardDemiBoldFontWithSize:17.0f],
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }];
    
    // UISwitch
    [[UISwitch appearance] setOnTintColor:[UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
    
    // UISegmentedControl
    attributes = @{
                   NSFontAttributeName: [IMFont standardDemiBoldFontWithSize:13.0f],
                   NSForegroundColorAttributeName: [UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]
                   };
    
    [[UISegmentedControl appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
}

#pragma mark - Location services
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[IMReminderController sharedInstance] didReceiveLocalNotification:notification];
}

@end
