//
//  IMEventNotesTextView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 19/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEventNotesTextView.h"
#import "IMInputBaseViewController.h"

@implementation IMEventNotesTextView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setContentInset:UIEdgeInsetsMake(3.0f, 0.0f, 0.0f, 0.0f)];
    }
    return self;
}

#pragma mark - Logic
- (void)setContentOffset:(CGPoint)contentOffset
{
    [self setContentInset:UIEdgeInsetsMake(3.0f, 0.0f, 0.0f, 0.0f)];
    [super setContentOffset:contentOffset];
}

@end
