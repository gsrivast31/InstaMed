//
//  IMUIHintView.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 12/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IMUIHintView.h"

@interface IMUIHintView ()
{
    UIView *containerView;
    
    BOOL isRemoving;
    IMUIHintCallback presentCallback;
    IMUIHintCallback dismissCallback;
}

@property (nonatomic, retain) UILabel *label;
@end

@implementation IMUIHintView
@synthesize label = _label;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame text:(NSString *)text presentationCallback:(IMUIHintCallback)present dismissCallback:(IMUIHintCallback)dismiss
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        isRemoving = NO;
        presentCallback = present;
        dismissCallback = dismiss;

        containerView = [[UIView alloc] initWithFrame:CGRectMake(15.0f, frame.size.height/2.0f - 20.0f, frame.size.width-30.0f, 40.0f)];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        containerView.alpha = 0.0f;
        
        UIView *messageBackground = [[UIView alloc] initWithFrame:containerView.bounds];
        messageBackground.layer.cornerRadius = 20.0f;
        messageBackground.backgroundColor = [UIColor colorWithRed:21.0f/255.0f green:207.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        [containerView addSubview:messageBackground];
                                     
        _label = [[UILabel alloc] initWithFrame:CGRectInset(messageBackground.frame, 10.0f, 0.0f)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [IMFont standardDemiBoldFontWithSize:16.0f];
        _label.text = text;
        _label.adjustsFontSizeToFitWidth = YES;
        [messageBackground addSubview:_label];
        [self addSubview:containerView];
    }
    return self;
}

#pragma mark - Logic
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(!isRemoving) [self dismiss];
    return NO;
}
- (void)present
{
    [UIView animateWithDuration:0.25 animations:^{
        presentCallback();
        
        containerView.alpha = 1.0f;
    }];
}
- (void)dismiss
{
    if(isRemoving) return;
    
    dismissCallback();
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.75 animations:^{
        containerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_4);
        containerView.frame = CGRectMake(-weakSelf.frame.size.width/4.0f, weakSelf.label.frame.origin.y+weakSelf.frame.size.height*2, weakSelf.label.frame.size.width, weakSelf.label.frame.size.height);
        containerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    isRemoving = YES;
}

@end
