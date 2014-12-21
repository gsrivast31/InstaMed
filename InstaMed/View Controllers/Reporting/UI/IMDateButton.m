//
//  IMDateButton.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IMDateButton.h"

@implementation IMDateButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setAdjustsImageWhenHighlighted:NO];
        [[self titleLabel] setFont:[IMFont standardDemiBoldFontWithSize:14.0f]];
        [self setTitleColor:[UIColor colorWithRed:115.0f/255.0f green:127.0f/255.0f blue:123.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"ReportsDateButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13.0f, 13.0f, 14.0f, 13.0f)] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"ReportsDateButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13.0f, 13.0f, 14.0f, 13.0f)] forState:UIControlStateHighlighted];
    }
    return self;
}

@end
