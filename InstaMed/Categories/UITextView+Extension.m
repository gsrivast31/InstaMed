//
//  UITextView+Extension.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "UITextView+Extension.h"

@implementation UITextView (Extension)

// This is based on a stackoverflow.com answer that hacks around iOS 7's inability to return a correct contentSize for UITextView
// The original version of this code can be found here: http://stackoverflow.com/a/19047464
- (CGFloat)height
{
    UITextView *textView = self;
    CGRect frame = textView.bounds;
    
    UIEdgeInsets textContainerInsets = textView.textContainerInset;
    UIEdgeInsets contentInsets = textView.contentInset;
    
    CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
    CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
    
    frame.size.width -= leftRightPadding;
    frame.size.height -= topBottomPadding;
    
    NSString *textToMeasure = textView.text;
    if ([textToMeasure hasSuffix:@"\n"])
    {
        textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attributes = @{NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle};
    
    CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
    return measuredHeight;
}

@end
