//
//  IMAnalyticsBaseChartViewController.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsBaseChartViewController.h"

// Views
#import "IMAnalyticsChartTooltipTipView.h"
#import "IMCoreDataStack.h"

// Numerics
CGFloat const kJBBaseChartViewControllerAnimationDuration = 0.25f;

@interface IMAnalyticsBaseChartViewController ()

@property (nonatomic, strong) IMAnalyticsChartTooltipView *tooltipView;
@property (nonatomic, strong) IMAnalyticsChartTooltipTipView *tooltipTipView;

@end

@implementation IMAnalyticsBaseChartViewController

- (id)initWithFromDate:(NSDate*)aFromDate toDate:(NSDate*)aToDate {
    self = [super init];
    if (self) {
        // If we're passed invalid dates, default to the current month
        if(!aFromDate) aFromDate = [[NSDate date] dateAtStartOfMonth];
        if(!aToDate) aToDate = [[NSDate date] dateAtEndOfMonth];
        
        fromDate = aFromDate;
        toDate = aToDate;
        reportData = nil;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        [self fetchReportData];
    }
    return self;
}

#pragma mark - Setters

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint
{
    _tooltipVisible = tooltipVisible;
    
    JBChartView *chartView = [self chartView];
    
    if (!chartView)
    {
        return;
    }
    
    if (!self.tooltipView)
    {
        self.tooltipView = [[IMAnalyticsChartTooltipView alloc] init];
        self.tooltipView.alpha = 0.0;
        [self.view addSubview:self.tooltipView];
    }
    
    if (!self.tooltipTipView)
    {
        self.tooltipTipView = [[IMAnalyticsChartTooltipTipView alloc] init];
        self.tooltipTipView.alpha = 0.0;
        [self.view addSubview:self.tooltipTipView];
    }
    
    dispatch_block_t adjustTooltipPosition = ^{
        CGPoint originalTouchPoint = [self.view convertPoint:touchPoint fromView:chartView];
        CGPoint convertedTouchPoint = originalTouchPoint; // modified
        JBChartView *chartView = [self chartView];
        if (chartView)
        {
            CGFloat minChartX = (chartView.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x < minChartX)
            {
                convertedTouchPoint.x = minChartX;
            }
            CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x > maxChartX)
            {
                convertedTouchPoint.x = maxChartX;
            }
            self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5), CGRectGetMaxY(chartView.headerView.frame), self.tooltipView.frame.size.width, self.tooltipView.frame.size.height);
            
            CGFloat minTipX = (chartView.frame.origin.x + self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x < minTipX)
            {
                originalTouchPoint.x = minTipX;
            }
            CGFloat maxTipX = (chartView.frame.origin.x + chartView.frame.size.width - self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x > maxTipX)
            {
                originalTouchPoint.x = maxTipX;
            }
            self.tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5), CGRectGetMaxY(self.tooltipView.frame), self.tooltipTipView.frame.size.width, self.tooltipTipView.frame.size.height);
        }
    };
    
    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = _tooltipVisible ? 1.0 : 0.0;
        self.tooltipTipView.alpha = _tooltipVisible ? 1.0 : 0.0;
	};
    
    if (tooltipVisible)
    {
        adjustTooltipPosition();
    }
    
    if (animated)
    {
        [UIView animateWithDuration:kJBBaseChartViewControllerAnimationDuration animations:^{
            adjustTooltipVisibility();
        } completion:^(BOOL finished) {
            if (!tooltipVisible)
            {
                adjustTooltipPosition();
            }
        }];
    }
    else
    {
        adjustTooltipVisibility();
    }
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated
{
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible
{
    [self setTooltipVisible:tooltipVisible animated:NO];
}

#pragma mark - Getters

- (JBChartView *)chartView
{
    // Subclasses should return chart instance for tooltip functionality
    return nil;
}

#pragma mark - Logic

- (void)fetchReportData {
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        NSDate *fetchFromDate = [fromDate dateAtStartOfDay];
        NSDate *fetchToDate = [toDate dateAtEndOfDay];
        
        if(fetchFromDate) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMEvent" inManagedObjectContext:moc];
            [fetchRequest setEntity:entity];
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor];
            [fetchRequest setSortDescriptors:sortDescriptors];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"timestamp >= %@ && timestamp <= %@", fetchFromDate, fetchToDate]];
            
            NSError *error = nil;
            reportData = [moc executeFetchRequest:fetchRequest error:&error];
            
            if(error) {
                reportData = nil;
            }
        }
    }
}

@end
