//
//  IMNewEventTextBlockViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMNewEventTextBlockViewCell.h"

@implementation IMNewEventTextBlockViewCell

- (CGFloat)height
{
    CGFloat width = self.textView.bounds.size.width;
    CGSize size = [self.textView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    size.height += 5.0f;
    
    if(size.height < 44.0f) size.height = 44.0f;
    return size.height;
}
@end
