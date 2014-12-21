//
//  IMAnalyticsChartFooterView.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsBarChartFooterView.h"
#import "IMAnalyticsConstants.h"

// Numerics
CGFloat const kJBBarChartFooterPolygonViewDefaultPadding = 4.0f;

// Colors
static UIColor *kJBBarChartFooterViewDefaultBackgroundColor = nil;

@interface IMAnalyticsBarChartFooterView ()

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation IMAnalyticsBarChartFooterView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [IMAnalyticsBarChartFooterView class])
	{
		kJBBarChartFooterViewDefaultBackgroundColor = kJBColorBarChartControllerBackground;
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kJBBarChartFooterViewDefaultBackgroundColor;
        
        _padding = kJBBarChartFooterPolygonViewDefaultPadding;
        
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        _leftLabel.font = kJBFontFooterLabel;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.shadowColor = [UIColor blackColor];
        _leftLabel.shadowOffset = CGSizeMake(0, 1);
        _leftLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftLabel];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.font = kJBFontFooterLabel;
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.shadowColor = [UIColor blackColor];
        _rightLabel.shadowOffset = CGSizeMake(0, 1);
        _rightLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightLabel];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat xOffset = self.padding;
    CGFloat yOffset = 0;
    CGFloat width = ceil(self.bounds.size.width * 0.5) - self.padding;
    
    self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height);
    self.rightLabel.frame = CGRectMake(CGRectGetMaxX(_leftLabel.frame), yOffset, width, self.bounds.size.height);
}

@end
