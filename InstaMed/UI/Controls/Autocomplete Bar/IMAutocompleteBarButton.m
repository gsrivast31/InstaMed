//
//  IMAutocompleteBarButton.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 27/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAutocompleteBarButton.h"
#import <QuartzCore/QuartzCore.h>

@interface IMAutocompleteBarButton ()
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIColor *labelSelectedColor;

// Logic
- (void)updateState;

@end

@implementation IMAutocompleteBarButton
@synthesize labelColor = _labelColor;
@synthesize labelSelectedColor = _labelSelectedColor;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = 5.0f;
        self.layer.shadowColor = [UIColor colorWithRed:136.0f/255.0f green:138.0f/255.0f blue:142.0f/255.0f alpha:1.0f].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.layer.shadowRadius = 0.0f;
        self.layer.shadowOpacity = 1.0f;
        
        self.labelColor = [UIColor blackColor];
        self.labelSelectedColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
        self.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self setAdjustsImageWhenHighlighted:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setTitleColor:self.labelColor forState:UIControlStateNormal];
    }
    return self;
}

#pragma mark - Logic
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self updateState];
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self updateState];
}

#pragma mark - Logic
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    CGFloat padding = 10.0f;
    CGSize newSize = [title sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newSize.width + (padding*2.0f), self.frame.size.height);
}
- (void)updateState
{
    if([self isHighlighted] || [self isSelected])
    {
        [self setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
        [self setTitleColor:self.labelSelectedColor forState:UIControlStateNormal];
    }
    else
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setTitleColor:self.labelColor forState:UIControlStateNormal];
    }
}
- (void)setLabelColor:(UIColor *)aColor
{
    _labelColor = aColor;
    self.titleLabel.textColor = aColor;
    
    [self setNeedsDisplay];
}
@end
