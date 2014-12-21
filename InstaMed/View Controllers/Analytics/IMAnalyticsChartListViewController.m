//
//  IMAnalyticsChartListViewController.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsChartListViewController.h"

// Controllers
#import "IMAnalyticsBarChartViewController.h"
#import "IMAnalyticsLineChartViewController.h"
#import "IMAnalyticsAreaChartViewController.h"

// Views
#import "IMAnalyticsChartTableCell.h"

#import "IMAnalyticsConstants.h"

typedef NS_ENUM(NSInteger, IMAnalyticsChartListViewControllerRow){
	IMAnalyticsChartListViewControllerRowLineChart,
    IMAnalyticsChartListViewControllerRowBarChart,
    IMAnalyticsChartListViewControllerRowAreaChart,
    IMAnalyticsChartListViewControllerRowCount
};

// Strings
NSString * const kJBChartListViewControllerCellIdentifier = @"kJBChartListViewControllerCellIdentifier";

// Numerics
NSInteger const kJBChartListViewControllerCellHeight = 100;

@interface IMAnalyticsChartListViewController ()

@end

@implementation IMAnalyticsChartListViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    [self.tableView registerClass:[IMAnalyticsChartTableCell class] forCellReuseIdentifier:kJBChartListViewControllerCellIdentifier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return IMAnalyticsChartListViewControllerRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMAnalyticsChartTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kJBChartListViewControllerCellIdentifier forIndexPath:indexPath];
    
    NSString *text = nil;
    NSString *detailText = nil;
    IMAnalyticsChartTableCellType type = -1;
    switch (indexPath.row) {
        case IMAnalyticsChartListViewControllerRowLineChart:
            text = kJBStringLabelAverageDailyRainfall;
            detailText = kJBStringLabelSanFrancisco2013;
            type = IMAnalyticsChartTableCellTypeLineChart;
            break;
        case IMAnalyticsChartListViewControllerRowBarChart:
            text = kJBStringLabelAverageMonthlyTemperature;
            detailText = kJBStringLabelWorldwide2012;
            type = IMAnalyticsChartTableCellTypeBarChart;
            break;
        case IMAnalyticsChartListViewControllerRowAreaChart:
            text = kJBStringLabelAverageShineHours;
            detailText = kJBStringLabelWorldwide2011;
            type = IMAnalyticsChartTableCellTypeAreaChart;
            break;
        default:
            break;
    }
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detailText;
    cell.type = type;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kJBChartListViewControllerCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == IMAnalyticsChartListViewControllerRowLineChart)
    {
        IMAnalyticsLineChartViewController *lineChartController = [[IMAnalyticsLineChartViewController alloc] init];
        [self.navigationController pushViewController:lineChartController animated:YES];
    }
    else if (indexPath.row == IMAnalyticsChartListViewControllerRowBarChart)
    {
        //IMAnalyticsBarChartViewController *barChartController = [[IMAnalyticsBarChartViewController alloc] initWithFromDate:nil toDate:nil];
        IMAnalyticsBarChartViewController *barChartController = [[IMAnalyticsBarChartViewController alloc] init];
        
        [self.navigationController pushViewController:barChartController animated:YES];
    }
    else if (indexPath.row == IMAnalyticsChartListViewControllerRowAreaChart)
    {
        IMAnalyticsAreaChartViewController *areaChartController = [[IMAnalyticsAreaChartViewController alloc] init];
        [self.navigationController pushViewController:areaChartController animated:YES];
    }
}

@end
