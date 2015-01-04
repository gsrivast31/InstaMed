//
//  IMAnalyticsColorConstants.h
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

#pragma mark - Navigation

#define kIMColorNavigationBarTint UIColorFromHex(0xFFFFFF)
#define kIMColorNavigationTint UIColorFromHex(0x000000)

#pragma mark - Bar Chart

#define kIMColorBarChartControllerBackground UIColorFromHex(0x313131)
#define kIMColorBarChartBackground UIColorFromHex(0x3c3c3c)
#define kIMColorBarChartBarBlue UIColorFromHex(0x08bcef)
#define kIMColorBarChartBarGreen UIColorFromHex(0x34b234)
#define kIMColorBarChartHeaderSeparatorColor UIColorFromHex(0x686868)

#pragma mark - Line Chart

#define kIMColorLineChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kIMColorLineChartBackground UIColorFromHex(0xb7e3e4)
#define kIMColorLineChartHeader UIColorFromHex(0x1c474e)
#define kIMColorLineChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kIMColorLineChartDefaultSolidLineColor [UIColor colorWithWhite:1.0 alpha:0.5]
#define kIMColorLineChartDefaultSolidSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]
#define kIMColorLineChartDefaultDashedLineColor [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define kIMColorLineChartDefaultDashedSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]

#define mark - Area Chart

#define kIMColorAreaChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kIMColorAreaChartBackground UIColorFromHex(0xb7e3e4)
#define kIMColorAreaChartHeader UIColorFromHex(0x1c474e)
#define kIMColorAreaChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kIMColorAreaChartDefaultSunLineColor [UIColor clearColor]
#define kIMColorAreaChartDefaultSunAreaColor [UIColorFromHex(0xfcfb3a) colorWithAlphaComponent:0.5]
#define kIMColorAreaChartDefaultSunSelectedLineColor [UIColor clearColor]
#define kIMColorAreaChartDefaultSunSelectedAreaColor UIColorFromHex(0xfcfb3a)
#define kIMColorAreaChartDefaultMoonLineColor [UIColor clearColor]
#define kIMColorAreaChartDefaultMoonAreaColor [[UIColor blackColor] colorWithAlphaComponent:0.5]
#define kIMColorAreaChartDefaultMoonSelectedLineColor [UIColor clearColor]
#define kIMColorAreaChartDefaultMoonSelectedAreaColor [UIColor blackColor]

#pragma mark - Tooltips

#define kIMColorTooltipColor [UIColor colorWithWhite:1.0 alpha:0.9]
#define kIMColorTooltipTextColor UIColorFromHex(0x313131)
