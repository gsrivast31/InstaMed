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

- (id)initWithData:(NSArray *)theData from:(NSDate*)fromDate to:(NSDate*)toDate; {
    self = [super init];
    if (self) {
        chartData = [self parseData:theData];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        fromDateString = [dateFormatter stringFromDate:fromDate];
        toDateString = [dateFormatter stringFromDate:toDate];
    }
    return self;
}

#pragma mark - Logic
- (NSDictionary *)parseData:(NSArray *)theData {
    return nil;
}

- (BOOL)hasEnoughDataToShowChart {
    return NO;
}

#pragma mark - Setters

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint {
    _tooltipVisible = tooltipVisible;
    
    JBChartView *chartView = [self chartView];
    
    if (!chartView) {
        return;
    }
    
    if (!self.tooltipView) {
        self.tooltipView = [[IMAnalyticsChartTooltipView alloc] init];
        self.tooltipView.alpha = 0.0;
        [self.view addSubview:self.tooltipView];
    }
    
    if (!self.tooltipTipView) {
        self.tooltipTipView = [[IMAnalyticsChartTooltipTipView alloc] init];
        self.tooltipTipView.alpha = 0.0;
        [self.view addSubview:self.tooltipTipView];
    }
    
    dispatch_block_t adjustTooltipPosition = ^{
        CGPoint originalTouchPoint = [self.view convertPoint:touchPoint fromView:chartView];
        CGPoint convertedTouchPoint = originalTouchPoint; // modified
        JBChartView *chartView = [self chartView];
        if (chartView) {
            CGFloat minChartX = (chartView.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x < minChartX) {
                convertedTouchPoint.x = minChartX;
            }
            CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x > maxChartX) {
                convertedTouchPoint.x = maxChartX;
            }
            self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5), CGRectGetMaxY(chartView.headerView.frame), self.tooltipView.frame.size.width, self.tooltipView.frame.size.height);
            
            CGFloat minTipX = (chartView.frame.origin.x + self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x < minTipX) {
                originalTouchPoint.x = minTipX;
            }
            CGFloat maxTipX = (chartView.frame.origin.x + chartView.frame.size.width - self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x > maxTipX) {
                originalTouchPoint.x = maxTipX;
            }
            self.tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5), CGRectGetMaxY(self.tooltipView.frame), self.tooltipTipView.frame.size.width, self.tooltipTipView.frame.size.height);
        }
    };
    
    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = _tooltipVisible ? 1.0 : 0.0;
        self.tooltipTipView.alpha = _tooltipVisible ? 1.0 : 0.0;
	};
    
    if (tooltipVisible) {
        adjustTooltipPosition();
    }
    
    if (animated) {
        [UIView animateWithDuration:kJBBaseChartViewControllerAnimationDuration animations:^{
            adjustTooltipVisibility();
        } completion:^(BOOL finished) {
            if (!tooltipVisible) {
                adjustTooltipPosition();
            }
        }];
    } else {
        adjustTooltipVisibility();
    }
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated {
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible {
    [self setTooltipVisible:tooltipVisible animated:NO];
}

#pragma mark - Getters

- (JBChartView *)chartView {
    // Subclasses should return chart instance for tooltip functionality
    return nil;
}

- (NSString*)dateString {
    if ([fromDateString isEqualToString:toDateString]) {
        return fromDateString;
    } else {
        return [NSString stringWithFormat:@"%@ - %@", fromDateString, toDateString];
    }
}


@end
