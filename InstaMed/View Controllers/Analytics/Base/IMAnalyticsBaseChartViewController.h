//
//  IMAnalyticsBaseChartViewController.h
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsBaseViewController.h"

// Views
#import "IMAnalyticsChartTooltipView.h"
#import "JBChartView.h"

@interface IMAnalyticsBaseChartViewController : IMAnalyticsBaseViewController
{
    NSArray *reports;
    NSArray *reportData;
    
    NSDateFormatter *dateFormatter;
    NSDate *toDate, *fromDate;
}

@property (nonatomic, strong, readonly) IMAnalyticsChartTooltipView *tooltipView;
@property (nonatomic, assign) BOOL tooltipVisible;


- (id)initWithFromDate:(NSDate*)aFromDate toDate:(NSDate*)aToDate;

// Setters
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint;
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated;

// Getters
- (JBChartView *)chartView; // subclasses to return chart instance for tooltip functionality

@end
