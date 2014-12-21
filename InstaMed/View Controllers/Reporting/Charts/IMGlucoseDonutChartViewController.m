//
//  IMGlucoseDonutChartViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 09/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <ShinobiCharts/SChartCanvas.h>
#import "IMGlucoseDonutChartViewController.h"

@implementation IMGlucoseDonutChartViewController

#pragma mark - Chart logic
- (NSDictionary *)parseData:(NSArray *)theData
{
    NSInteger userUnit = [IMHelper userBGUnit];
    NSNumber *healthyRangeMin = [IMHelper convertBGValue:[[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyBGKey] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
    NSNumber *healthyRangeMax = [IMHelper convertBGValue:[[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyBGKey] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
    
    CGFloat healthyBGValues = 0, unhealthyBGValues = 0, totalBGValues = 0;
    
    for(IMEvent *event in theData)
    {
        if([event isKindOfClass:[IMReading class]])
        {
            IMReading *reading = (IMReading *)event;
            if([reading.value doubleValue] >= [healthyRangeMin doubleValue] && [reading.value doubleValue] <= [healthyRangeMax doubleValue])
            {
                healthyBGValues++;
            }
            else
            {
                unhealthyBGValues++;
            }
            
            totalBGValues++;
        }
    }
    
    CGFloat healthyPercentage = totalBGValues > 0 ? ((healthyBGValues/totalBGValues)*100) : 0;
    CGFloat unhealthyPercentage = totalBGValues > 0 ? ((unhealthyBGValues/totalBGValues)*100) : 0;
    return @{@"healthyBGValues": [NSNumber numberWithFloat:healthyPercentage], @"unhealthyBGValues": [NSNumber numberWithFloat:unhealthyPercentage]};
}
- (void)setupChart
{
    // Don't allow us to setup our chart more than once
    if(self.chart) return;
    
    if([[chartData objectForKey:@"healthyBGValues"] integerValue] != 0 || [[chartData objectForKey:@"unhealthyBGValues"] integerValue] != 0)
    {
        self.chart = [[ShinobiChart alloc] initWithFrame:self.view.bounds];
        self.chart.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.chart.clipsToBounds = NO;
        self.chart.datasource = self;
        self.chart.delegate = self;
        self.chart.rotatesOnDeviceRotation = NO;
        self.chart.backgroundColor = [UIColor clearColor];
        self.chart.canvasAreaBackgroundColor = [UIColor clearColor];
        self.chart.plotAreaBackgroundColor = [UIColor clearColor];
        self.chart.borderThickness = [NSNumber numberWithDouble:1.0f];
        self.chart.gesturePinchAspectLock = YES;
        self.chart.legend.hidden = YES;
        [self.chart applyTheme:[SChartLightTheme new]];
        
        [self.view insertSubview:self.chart belowSubview:closeButton];
    }
}
- (BOOL)hasEnoughDataToShowChart
{
    if([[chartData objectForKey:@"healthyBGValues"] integerValue] != 0 || [[chartData objectForKey:@"unhealthyBGValues"] integerValue] != 0)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - SChartDataSource methods
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart
{
    return 1;
}
- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex
{
    return 2;
}
- (SChartSeries*)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)seriesIndex
{
    SChartDonutSeries *series = [SChartDonutSeries new];
    series.style.showCrust = NO;
    
    series.style.flavourColors = [NSMutableArray arrayWithObjects:[UIColor colorWithRed:77.0f/255.0f green:179.0f/255.0f blue:177.0f/255.0f alpha:1.0f], [UIColor colorWithRed:254.0f/255.0f green:110.0f/255.0f blue:116.0f/255.0f alpha:1.0f], nil];
    series.selectedStyle.showCrust = NO;
    series.labelFormatString = @"%.0f%%";
    //series.style.labelFont = [UIFont fontWithName:self.theme.lightFontName size:16.f];
    series.outerRadius = 75.f;
    series.innerRadius = 35.f;
    series.selectedStyle.protrusion = 0.f;
    
    return series;
}
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    SChartRadialDataPoint *point = [SChartRadialDataPoint new];
    
    if(dataIndex == 0)
    {
        point.name = NSLocalizedString(@"Healthy", @"A label used to show healthy blood glucose readings");
        point.value = [chartData objectForKey:@"healthyBGValues"];
    }
    else
    {
        point.name = NSLocalizedString(@"Unhealthy", @"A label used to show unhealthy blood glucose readings");
        point.value = [chartData objectForKey:@"unhealthyBGValues"];
    }
    
    return point;
}
- (void)sChart:(ShinobiChart *)chart alterLabel:(UILabel *)label forDatapoint:(SChartRadialDataPoint *)datapoint atSliceIndex:(NSInteger)index inRadialSeries:(SChartRadialSeries *)series
{
    //For our donut move our labels outside and use connecting lines
    if (datapoint.value.floatValue < 2.0f)
    {
        label.text = @"";
    }
    else
    {
        float extrusion = 40.0f;
        
        SChartPieSeries *pieSeries = (SChartPieSeries *)series;
        
        // three points:
        CGPoint pieCenter;
        CGPoint oldLabelCenter;
        CGPoint labelCenter;
        
        pieCenter = [pieSeries getDonutCenter];
        oldLabelCenter = labelCenter = [pieSeries getSliceCenter:index];
        
        float xChange, yChange;
        xChange = pieCenter.x - labelCenter.x;
        yChange = pieCenter.y - labelCenter.y;
        
        float angle = atan2f(xChange, yChange) + M_PI / 2.f;
        labelCenter.x = oldLabelCenter.x + (extrusion+10.0f) * cosf(angle);
        labelCenter.y = oldLabelCenter.y - (extrusion+15.0f) * sinf(angle);
        
        label.textColor = [UIColor lightGrayColor];
        [label setText:[NSString stringWithFormat:@"%@\n%.0f%%", datapoint.xValue, [datapoint.yValue floatValue]]];
        [label setNumberOfLines:2];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFrame:CGRectMake(0.0f, 0.0f, 100.0f, 50.0f)];
        [label setCenter:labelCenter]; // this must be after sizeToFit
        [label setHidden:NO];
    }
}

@end