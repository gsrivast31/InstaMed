//
//  IMInputLabel.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMInputLabel.h"

@implementation IMInputLabel

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Logic
- (BOOL)isUserInteractionEnabled
{
    return YES;
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate inputLabelDidBeginEditing:self];
    [self becomeFirstResponder];
}

@end
