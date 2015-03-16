//
//  IMGenericTableHeaderView.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 16/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMGenericTableHeaderView.h"

@interface IMGenericTableHeaderView ()
@property (nonatomic, retain) UILabel *label;
@end

@implementation IMGenericTableHeaderView
@synthesize label = _label;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, frame.size.height-24.0f, frame.size.width-40.0f, 16.0f)];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [IMFont standardDemiBoldFontWithSize:14.0f];
        _label.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        
        [self addSubview:_label];
    }
    return self;
}

#pragma mark - Logic
- (void)setText:(NSString *)text
{
    _label.text = [text uppercaseString];
}

@end
