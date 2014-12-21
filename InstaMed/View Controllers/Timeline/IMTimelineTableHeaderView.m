//
//  IMTimelineTableHeaderView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 23/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMTimelineTableHeaderView.h"

@implementation IMTimelineTableHeaderView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)aTitle
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [IMFont standardDemiBoldFontWithSize:12.0f];
        label.text = [aTitle uppercaseString];
        label.textColor = [UIColor colorWithRed:154.0f/255.0f green:152.0f/255.0f blue:147.0f/255.0f alpha:1.0f];
        label.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        
        self.clipsToBounds = NO;
    }
    
    return self;
}

#pragma mark - Rendering
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIImage *bg = [UIImage imageNamed:@"GeneralSectionHeader.png"];
    [bg drawInRect:self.frame];
}

@end