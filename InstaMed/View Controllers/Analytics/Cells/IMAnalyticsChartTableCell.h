//
//  IMAnalyticsChartTableCell.h
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IMAnalyticsChartTableCellType){
	IMAnalyticsChartTableCellTypeLineChart,
    IMAnalyticsChartTableCellTypeBarChart,
    IMAnalyticsChartTableCellTypeAreaChart
};

@interface IMAnalyticsChartTableCell : UITableViewCell

@property (nonatomic, assign) IMAnalyticsChartTableCellType type;

@end
