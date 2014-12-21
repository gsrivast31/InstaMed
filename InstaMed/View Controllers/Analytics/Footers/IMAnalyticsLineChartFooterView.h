//
//  IMAnalyticsLineChartFooterView.h
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMAnalyticsLineChartFooterView : UIView

@property (nonatomic, strong) UIColor *footerSeparatorColor; // footer separator (default = white)
@property (nonatomic, assign) NSInteger sectionCount; // # of notches (default = 2 on each edge)
@property (nonatomic, readonly) UILabel *leftLabel;
@property (nonatomic, readonly) UILabel *rightLabel;

@end
