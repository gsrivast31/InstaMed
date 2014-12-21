//
//  IMNavPaginationTitleView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMNavPaginationTitleView.h"

@implementation IMNavPaginationTitleView
@synthesize titleLabel = _titleLabel;
@synthesize pageControl = _pageControl;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 6.0f, frame.size.width, 16.0f)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [IMFont standardDemiBoldFontWithSize:16.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        
        _pageControl = [[IMNavPageControl alloc] initWithFrame:CGRectMake(0.0f, 25.0f, frame.size.width, 16.0f)];
            
        [self addSubview:_titleLabel];
        [self addSubview:_pageControl];
    }
    return self;
}

#pragma mark - Logic
- (void)setTitle:(NSString *)title
{
    _titleLabel.text = [title uppercaseString];
}

@end
