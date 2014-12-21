//
//  IMChartCrosshairTooltip.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 17/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMChartCrosshairTooltip.h"

@implementation IMChartCrosshairTooltip

#pragma mark - Logic
- (void)setDataPoint:(id<SChartData>)dataPoint fromSeries:(SChartSeries *)series fromChart:(ShinobiChart *)chart
{
    self.label.text = [chart.yAxis stringForValue:[[dataPoint sChartYValue] doubleValue]];
}

@end
