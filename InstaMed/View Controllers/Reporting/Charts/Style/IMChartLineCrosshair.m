//
//  IMChartLineCrosshair.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 17/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMChartLineCrosshair.h"
#import "IMChartCrosshairTooltip.h"

@implementation IMChartLineCrosshair

#pragma mark - Setup
- (id)initWithChart:(ShinobiChart *)parentChart
{
    self = [super initWithChart:parentChart];
    if (self) {
        self.tooltip = [[IMChartCrosshairTooltip alloc] init];
        
        self.interpolatePoints = NO;
        self.outOfRangeBehavior = SChartCrosshairOutOfRangeBehaviorHide;
    }
    return self;
}

@end
