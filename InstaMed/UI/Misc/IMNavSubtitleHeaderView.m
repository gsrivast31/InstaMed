//
//  IMNavSubtitleHeaderView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMNavSubtitleHeaderView.h"

@implementation IMNavSubtitleHeaderView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 6.0f, frame.size.width, 16.0f)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [IMFont standardBoldFontWithSize:15.0f];
        _titleLabel.shadowColor = [UIColor colorWithRed:26.0f/255.0f green:148.0f/255.0f blue:111.0f/255.0f alpha:1.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 22.0f, frame.size.width, 16.0f)];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.font = [IMFont standardDemiBoldFontWithSize:13.0f];
        _subtitleLabel.shadowColor = [UIColor colorWithRed:26.0f/255.0f green:148.0f/255.0f blue:111.0f/255.0f alpha:1.0];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_titleLabel];
        [self addSubview:_subtitleLabel];
    }
    return self;
}

#pragma mark - Logic
- (void)setTitle:(NSString *)title
{
    _titleLabel.text = [title uppercaseString];
}
- (void)setSubtitle:(NSString *)subtitle
{
    _subtitleLabel.text = subtitle;
}

@end