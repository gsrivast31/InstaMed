//
//  IMAnalyticsBaseNavigationController.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsBaseNavigationController.h"
#import "IMAnalyticsConstants.h"

#import "IMAnalyticsCarbsChartViewController.h"
#import "IMAnalyticsBPLineViewController.h"
#import "IMAnalyticsWeightLineViewController.h"
#import "IMAnalyticsAvgGlucoseBarViewController.h"
#import "IMAnalyticsAvgCholesterolBarViewController.h"
#import "IMAnalyticsGlucoseLineViewController.h"
#import "IMAnalyticsCholesterolLineViewController.h"

#import "IMHelper.h"

@interface IMAnalyticsBaseNavigationController ()
{
    NSArray* reportData;
    NSDate* fromDate;
    NSDate* toDate;
}

@property (strong, readwrite, nonatomic) REMenu *menu;

@end

@implementation IMAnalyticsBaseNavigationController

#pragma mark - Alloc/Init

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    return self;
}

- (void)setData:(NSArray*)data from:(NSDate*)aFromDate to:(NSDate*)aToDate {
    reportData = data;
    fromDate = aFromDate;
    toDate = aToDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (REUIKitIsFlatMode()) {
        [self.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:0/255.0 green:213/255.0 blue:161/255.0 alpha:1]];
        self.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationBar.tintColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
    }
    
    __typeof (self) __weak weakSelf = self;
    NSInteger tag = 0;
    NSMutableArray* itemArray = [[NSMutableArray alloc] init];

    REMenuItem *carbsItem = [[REMenuItem alloc] initWithTitle:@"Carbs Intake"
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          IMAnalyticsCarbsChartViewController* controller = [[IMAnalyticsCarbsChartViewController alloc] initWithData:reportData from:fromDate to:toDate];
                                                          [weakSelf setViewControllers:@[controller] animated:NO];
                                                      }];
    carbsItem.tag = tag;
    [itemArray addObject:carbsItem];

    if ([IMHelper includeBPReadings]) {
        REMenuItem *bpItem = [[REMenuItem alloc] initWithTitle:@"Blood Pressure Levels"
                                                         image:nil
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            IMAnalyticsBPLineViewController* controller = [[IMAnalyticsBPLineViewController alloc] initWithData:reportData from:fromDate to:toDate];
                                                            [weakSelf setViewControllers:@[controller] animated:NO];
                                                        }];
        bpItem.tag = ++tag;
        [itemArray addObject:bpItem];
    }
    
    if ([IMHelper includeWeightReadings]) {
        REMenuItem *weightItem = [[REMenuItem alloc] initWithTitle:@"Weights"
                                                             image:nil
                                                  highlightedImage:nil
                                                            action:^(REMenuItem *item) {
                                                                IMAnalyticsWeightLineViewController* controller = [[IMAnalyticsWeightLineViewController alloc] initWithData:reportData from:fromDate to:toDate];
                                                                [weakSelf setViewControllers:@[controller] animated:NO];
                                                            }];
        weightItem.tag = ++tag;
        [itemArray addObject:weightItem];
    }

    if ([IMHelper includeGlucoseReadings]) {
        REMenuItem *avgGlucoseItem = [[REMenuItem alloc] initWithTitle:@"Avg Blood Glucose"
                                                                 image:nil
                                                      highlightedImage:nil
                                                                action:^(REMenuItem *item) {
                                                                    IMAnalyticsAvgGlucoseBarViewController* controller = [[IMAnalyticsAvgGlucoseBarViewController alloc] initWithData:reportData from:fromDate to:toDate];
                                                                    [weakSelf setViewControllers:@[controller] animated:NO];
                                                                }];

        REMenuItem *glucoseItem = [[REMenuItem alloc] initWithTitle:@"Glucose Deviations"
                                                              image:nil
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 IMAnalyticsGlucoseLineViewController* controller = [[IMAnalyticsGlucoseLineViewController alloc] initWithData:reportData from:fromDate to:toDate];
                                                                 [weakSelf setViewControllers:@[controller] animated:NO];
                                                             }];

        avgGlucoseItem.tag = ++tag;
        glucoseItem.tag = ++tag;
        [itemArray addObject:avgGlucoseItem];
        [itemArray addObject:glucoseItem];
    }

    if ([IMHelper includeCholesterolReadings]) {
        REMenuItem *avgChItem = [[REMenuItem alloc] initWithTitle:@"Avg Cholesterol"
                                                            image:nil
                                                 highlightedImage:nil
                                                           action:^(REMenuItem *item) {
                                                               IMAnalyticsAvgCholesterolBarViewController* controller = [[IMAnalyticsAvgCholesterolBarViewController alloc] initWithData:reportData from:fromDate to:toDate];
                                                               [weakSelf setViewControllers:@[controller] animated:NO];
                                                           }];
        
        
        REMenuItem *chItem = [[REMenuItem alloc] initWithTitle:@"Cholesterol Deviations"
                                                         image:nil
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            IMAnalyticsCholesterolLineViewController* controller = [[IMAnalyticsCholesterolLineViewController alloc] initWithData:reportData from:fromDate to:toDate];
                                                            [weakSelf setViewControllers:@[controller] animated:NO];
                                                        }];
        avgChItem.tag = ++tag;
        chItem.tag = ++tag;
        [itemArray addObject:avgChItem];
        [itemArray addObject:chItem];

    }

    self.menu = [[REMenu alloc] initWithItems:itemArray];
    
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    self.menu.separatorOffset = CGSizeMake(15.0, 0.0);
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    [self.menu setClosePreparationBlock:^{
    }];
    
    [self.menu setCloseCompletionHandler:^{
    }];
    
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleMenu {
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self];
}

@end
