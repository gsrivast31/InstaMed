//
//  IMAddEntryModaliPadButton.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/01/2014.
//  Copyright 2014 GAURAV SRIVASTAVA
//

#import "IMAddEntryModaliPadButton.h"

@implementation IMAddEntryModaliPadButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [IMFont standardRegularFontWithSize:18.0f];

        [self setTitleColor:[UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25.0f, 0)];
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0.0f, self.bounds.size.height-20.0f, self.bounds.size.width, 20.0f);
    self.imageView.frame = CGRectMake(0.0f, 0.0f, 105.0f, 105.0f);
}

@end
