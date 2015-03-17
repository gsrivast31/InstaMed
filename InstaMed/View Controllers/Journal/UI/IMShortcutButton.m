//
//  IMShortcutButton.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 27/08/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMShortcutButton.h"

@implementation IMShortcutButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setTitleColor:[UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        
        self.titleLabel.font = [IMFont standardMediumFontWithSize:12.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(floorf(self.bounds.size.width/2.0f - self.imageView.image.size.width/2.0f), floorf(self.bounds.size.height/2.0f - 39.0f), floorf(self.imageView.image.size.width), floorf(self.imageView.image.size.height));
    self.titleLabel.frame = CGRectMake(0, floorf(self.bounds.size.height/2.0f + 27.0f), self.bounds.size.width, 16.0f);
}

@end
