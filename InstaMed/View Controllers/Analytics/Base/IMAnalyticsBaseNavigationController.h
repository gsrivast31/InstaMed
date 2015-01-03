//
//  IMAnalyticsBaseNavigationController.h
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "REMenu.h"

@interface IMAnalyticsBaseNavigationController : UINavigationController

@property (strong, readonly, nonatomic) REMenu *menu;

- (void)setData:(NSArray *)data from:(NSDate*)fromDate to:(NSDate*)toDate;

- (void)dismissSelf;
- (void)toggleMenu;
@end
