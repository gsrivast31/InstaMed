//
//  IMAnalyticsChartTooltipView.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsChartTooltipView.h"
#import "IMAnalyticsConstants.h"

// Drawing
#import <QuartzCore/QuartzCore.h>

// Numerics
CGFloat static const kJBChartTooltipViewCornerRadius = 5.0;
CGFloat const kJBChartTooltipViewDefaultWidth = 50.0f;
CGFloat const kJBChartTooltipViewDefaultHeight = 25.0f;

@interface IMAnalyticsChartTooltipView ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation IMAnalyticsChartTooltipView

#pragma mark - Alloc/Init

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kJBChartTooltipViewDefaultWidth, kJBChartTooltipViewDefaultHeight)];
    if (self)
    {
        self.backgroundColor = kIMColorTooltipColor;
        self.layer.cornerRadius = kJBChartTooltipViewCornerRadius;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = kJBFontTooltipText;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = kIMColorTooltipTextColor;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 1;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    return self;
}

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    [self setNeedsLayout];
}

- (void)setTooltipColor:(UIColor *)tooltipColor
{
    self.backgroundColor = tooltipColor;
    [self setNeedsDisplay];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
}

@end
