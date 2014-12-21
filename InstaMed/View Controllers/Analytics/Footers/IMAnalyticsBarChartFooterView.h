//
//  IMAnalyticsBarChartFooterView.h
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMAnalyticsBarChartFooterView : UIView

@property (nonatomic, assign) CGFloat padding; // label left & right padding (default = 4.0)
@property (nonatomic, readonly) UILabel *leftLabel;
@property (nonatomic, readonly) UILabel *rightLabel;

@end
