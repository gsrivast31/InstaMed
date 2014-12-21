//
//  IMChartViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 17/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <ShinobiCharts/ShinobiChart.h>
#import "NSDate+Extension.h"
#import "IMBaseViewController.h"

@interface IMChartViewController : IMBaseViewController
{
    NSDictionary *chartData;
    UIButton *closeButton;
}

@property (nonatomic, strong) ShinobiChart *chart;
@property (nonatomic, assign) CGRect initialRect;

// Setup
- (id)initWithData:(NSArray *)data;
- (void)setupChart;
- (NSDictionary *)parseData:(NSArray *)theData;

// Logic
- (BOOL)hasEnoughDataToShowChart;

@end
