//
//  IMKeyboardShortcutButton.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 31/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMKeyboardShortcutButton.h"

@implementation IMKeyboardShortcutButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.0f;
        //self.layer.masksToBounds = YES;
        
       // self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.adjustsImageWhenDisabled = NO;
        
        self.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.layer.shadowColor = [UIColor colorWithRed:136.0f/255.0f green:138.0f/255.0f blue:142.0f/255.0f alpha:1.0f].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.layer.shadowRadius = 0.0f;
        self.layer.shadowOpacity = 1.0f;
    }
    return self;
}

#pragma mark - Logic
- (void)setHighlighted:(BOOL)highlighted
{
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}
- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.alpha = enabled ? 1.0f : 0.35f;
}
- (void)showActivityIndicator:(BOOL)state
{
    [[self imageView] setHidden:state];
    [[self activityIndicatorView] setHidden:!state];
    
    if(state)
    {
        [[self activityIndicatorView] startAnimating];
    }
    else
    {
        [[self activityIndicatorView] stopAnimating];
    }
}

#pragma mark - Accessors
- (UIImageView *)fullsizeImageView
{
    if(!_fullsizeImageView)
    {
        _fullsizeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _fullsizeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fullsizeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_fullsizeImageView aboveSubview:self.imageView];
    }
    
    return _fullsizeImageView;
}
- (UIActivityIndicatorView *)activityIndicatorView
{
    if(!_activityIndicatorView)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        _activityIndicatorView.hidden = NO;
        _activityIndicatorView.backgroundColor = [UIColor clearColor];
        _activityIndicatorView.color = [UIColor blackColor];
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _activityIndicatorView.userInteractionEnabled = NO;
        _activityIndicatorView.hidesWhenStopped = YES;
        [self insertSubview:_activityIndicatorView aboveSubview:self.imageView];
    }
    
    return _activityIndicatorView;
}

@end
