//
//  IMAnalyticsChartInformationView.h
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMAnalyticsChartInformationView : UIView

/*
 * View must be initialized with a layout type (default = horizontal)
 */
- (id)initWithFrame:(CGRect)frame;

// Content
- (void)setTitleText:(NSString *)titleText;
- (void)setValueText:(NSString *)valueText unitText:(NSString *)unitText;

// Color
- (void)setTitleTextColor:(UIColor *)titleTextColor;
- (void)setValueAndUnitTextColor:(UIColor *)valueAndUnitColor;
- (void)setTextShadowColor:(UIColor *)shadowColor;
- (void)setSeparatorColor:(UIColor *)separatorColor;

// Visibility
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end
