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
    NSDictionary *chartData;
    NSString* fromDateString;
    NSString* toDateString;
}

@property (nonatomic, strong, readonly) IMAnalyticsChartTooltipView *tooltipView;
@property (nonatomic, assign) BOOL tooltipVisible;

- (id)initWithData:(NSArray *)data from:(NSDate*)fromDate to:(NSDate*)toDate;
- (NSDictionary *)parseData:(NSArray *)theData;
- (BOOL)hasEnoughDataToShowChart;
- (NSString*)dateString;

// Setters
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint;
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated;

// Getters
- (JBChartView *)chartView; // subclasses to return chart instance for tooltip functionality

@end
