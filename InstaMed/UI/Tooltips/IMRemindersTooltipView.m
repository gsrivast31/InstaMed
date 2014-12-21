//
//  IMRemindersTooltipView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMRemindersTooltipView.h"

@interface IMRemindersTooltipView ()
{
    UIView *border, *containerView;
    UILabel *header, *content;
}
@end

@implementation IMRemindersTooltipView

#pragma mark - Logic
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        border = [[UIView alloc] initWithFrame:CGRectZero];
        border.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:237.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
        [containerView addSubview:border];
        
        header = [[UILabel alloc] initWithFrame:CGRectZero];
        header.backgroundColor = [UIColor clearColor];
        header.textColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
        header.numberOfLines = 1;
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [IMFont standardBoldFontWithSize:26.0f];
        header.text = NSLocalizedString(@"Reminders", nil);
        header.adjustsFontSizeToFitWidth = YES;
        header.minimumScaleFactor = 0.5f;
        [containerView addSubview:header];
        
        content = [[UILabel alloc] initWithFrame:CGRectZero];
        content.backgroundColor = [UIColor clearColor];
        content.textColor = [UIColor colorWithRed:115.0f/255.0f green:128.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
        content.numberOfLines = 0;
        content.textAlignment = NSTextAlignmentCenter;
        content.font = [IMFont standardRegularFontWithSize:16.0f];
        content.text = NSLocalizedString(@"Reminders are a great way to keep on top of things.\n\nAlong with one-time and repeat reminders you can also setup location-based reminders to alert you when you leave or arrive at a particular location.", nil);
        [containerView addSubview:content];
        [self addSubview:containerView];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentHeight = 200.0f, headerHeight = 30.0f;
    
    border.frame = CGRectMake(floorf(self.frame.size.width/2 - 20), headerHeight+10, 40, 2);
    containerView.frame = CGRectMake(0, floorf(self.frame.size.height/2 - ((contentHeight+headerHeight)/2)), self.frame.size.width, contentHeight+headerHeight);
    header.frame = CGRectMake(floorf(self.frame.size.width/2 - 225/2), 0, 225, headerHeight);
    content.frame = CGRectMake(floorf(self.frame.size.width/2 - 225/2), headerHeight+20, 225, contentHeight);
    
}

@end
