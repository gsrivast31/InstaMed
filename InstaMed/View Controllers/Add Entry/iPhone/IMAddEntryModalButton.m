//
//  IMAddEntryModalButton.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAddEntryModalButton.h"

#define kLabelSpacing 20.0f

@implementation IMAddEntryModalButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
        self.titleLabel.font = [IMFont standardMediumFontWithSize:15.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        //[self setTitleColor:[UIColor colorWithRed:143.0f/255.0f green:153.0f/255.0f blue:150.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:119.0f/255.0f green:127.0f/255.0f blue:125.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(floorf(self.bounds.size.width/2-self.imageView.image.size.width/2), floorf(self.bounds.size.height/2 - self.imageView.image.size.height/2)-kLabelSpacing, self.imageView.image.size.width, self.imageView.image.size.height);
    self.titleLabel.frame = CGRectMake(0.0f, floorf(self.frame.size.height/2 + kLabelSpacing), self.frame.size.width, 18.0f);
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:244.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
    }
}
- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if(enabled)
    {
        [self setTitleColor:[UIColor colorWithRed:148.0f/255.0f green:148.0f/255.0f blue:148.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    else
    {
        [self setTitleColor:[UIColor colorWithRed:97.0f/255.0f green:97.0f/255.0f blue:97.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
}
@end
