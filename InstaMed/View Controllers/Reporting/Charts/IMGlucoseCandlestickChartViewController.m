//
//  IMGlucoseCandlestickChartViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 20/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMGlucoseCandlestickChartViewController.h"
#import "IMChartLineCrosshair.h"
#import "OrderedDictionary.h"
#import "IMLeastSquareFitCalculator.h"

@interface IMGlucoseCandlestickChartViewController ()
{
    double lowestReading;
}
@end

@implementation IMGlucoseCandlestickChartViewController

#pragma mark - Chart logic
- (NSDictionary *)parseData:(NSArray *)theData
{
    lowestReading = 999999.0f;
    
    NSDate *minDate = [NSDate distantFuture];
    NSDate *maxDate = [NSDate distantPast];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    OrderedDictionary *dictionary = [OrderedDictionary dictionary];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    theData = [theData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for(IMEvent *event in theData)
    {
        if([event isKindOfClass:[IMReading class]])
        {
            NSDate *timestamp = [event.timestamp dateAtStartOfDay];
            if([timestamp isEarlierThanDate:minDate]) minDate = timestamp;
            if([timestamp isLaterThanDate:maxDate]) maxDate = timestamp;
            
            NSMutableArray *events = nil;
            NSString *key = [dateFormatter stringFromDate:timestamp];
            if(!dictionary[key])
            {
                events = [NSMutableArray array];
            }
            else
            {
                events = [NSMutableArray arrayWithArray:[dictionary objectForKey:key]];
            }
            [events addObject:event];
            
            dictionary[key] = events;
        }
    }
    
    NSMutableDictionary *formattedData = [NSMutableDictionary dictionary];
    for(NSString *date in dictionary)
    {
        if([dictionary[date] count] > 1)
        {
            IMReading *lowReading = nil;
            IMReading *highReading = nil;
            for(IMReading *reading in dictionary[date])
            {
                if([reading.value doubleValue] < lowestReading) lowestReading = [reading.value doubleValue];
                if(!highReading || [reading.mmoValue doubleValue] > [highReading.mmoValue doubleValue]) highReading = reading;
                if(!lowReading || [reading.mmoValue doubleValue] < [lowReading.mmoValue doubleValue]) lowReading = reading;
            }
            formattedData[date] = @{@"open": [dictionary[date] firstObject], @"close": [dictionary[date] lastObject], @"low": lowReading, @"high": highReading};
        }
    }
    
    // Stop a crash from occuring if our minDate equals our maxDate
    if([minDate isEqualToDate:maxDate])
    {
        maxDate = [maxDate dateByAddingHours:1];
    }
    
    return @{@"minDate": minDate, @"maxDate": maxDate, @"data": formattedData};
}
- (BOOL)hasEnoughDataToShowChart
{
    if([[chartData objectForKey:@"data"] count] >= 1)
    {
        return YES;
    }
    
    return NO;
}
- (void)setupChart
{
    // Don't allow us to setup our chart more than once
    if(self.chart) return;
    
    if([[chartData objectForKey:@"data"] count])
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
        self.chart.crosshair = [[IMChartLineCrosshair alloc] initWithChart:self.chart];
        [self.chart applyTheme:[SChartLightTheme new]];
        
        //Double tap can either reset zoom or zoom in
        self.chart.gestureDoubleTapResetsZoom = YES;
        
        //Our xAxis is a category to take the discrete month data
        SChartDateRange *dateRange = [[SChartDateRange alloc] initWithDateMinimum:[chartData objectForKey:@"minDate"] andDateMaximum:[chartData objectForKey:@"maxDate"]];
        SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:dateRange];
        xAxis.enableGesturePanning = YES;
        xAxis.enableGestureZooming = YES;
        xAxis.enableMomentumPanning = YES;
        xAxis.enableMomentumZooming = YES;
        xAxis.allowPanningOutOfDefaultRange = NO;
        xAxis.allowPanningOutOfMaxRange = NO;
        self.chart.xAxis = xAxis;
        
        //Use a custom range to best display our data
        NSInteger userUnit = [IMHelper userBGUnit];
        NSNumber *gloodRangeMin = [IMHelper convertBGValue:[NSNumber numberWithFloat:lowestReading] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        NSNumber *gloodRangeMax = [IMHelper convertBGValue:[NSNumber numberWithFloat:25.0f] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        
        SChartNumberRange *r = [[SChartNumberRange alloc] initWithMinimum:gloodRangeMin andMaximum:gloodRangeMax];
        SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:r];
        yAxis.enableGesturePanning = YES;
        yAxis.enableGestureZooming = YES;
        yAxis.enableMomentumPanning = YES;
        yAxis.enableMomentumZooming = YES;
        yAxis.rangePaddingHigh = [NSNumber numberWithFloat:0.25f];
        yAxis.rangePaddingLow = [NSNumber numberWithFloat:0.25f];
        yAxis.title = NSLocalizedString(@"Blood Glucose Level", nil);
        yAxis.style.titleStyle.position = SChartTitlePositionCenter;
        self.chart.yAxis = yAxis;
        
        [self.view insertSubview:self.chart belowSubview:closeButton];
    }
}

#pragma mark - SChartDataSource methods
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart
{
     return 1;
}
- (SChartSeries*)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)seriesIndex
{
    if(seriesIndex == 0)
    {
        SChartCandlestickSeries *candlestickSeries = [[SChartCandlestickSeries alloc] init];
        return candlestickSeries;
    }
    
    return nil;
}
- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex
{
    return [[chartData objectForKey:@"data"] count];
}
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    SChartMultiYDataPoint *multiPoint = [[SChartMultiYDataPoint alloc] init];
    
    NSString *dateKey = [chartData[@"data"] allKeys][dataIndex];
    NSDictionary *dayData = chartData[@"data"][dateKey];
    NSDate *date = [[(IMReading *)dayData[@"open"] timestamp] dateAtStartOfDay];
    
    multiPoint.xValue = date;
    if(seriesIndex == 0)
    {
        multiPoint.yValues[SChartCandlestickKeyOpen] = [(IMReading *)dayData[@"open"] value];
        multiPoint.yValues[SChartCandlestickKeyClose] = [(IMReading *)dayData[@"close"] value];
        multiPoint.yValues[SChartCandlestickKeyLow] = [(IMReading *)dayData[@"low"] value];
        multiPoint.yValues[SChartCandlestickKeyHigh] = [(IMReading *)dayData[@"high"] value];
        
        return multiPoint;
    }
    
    return nil;
}

@end
