//
//  IMSettingsTextViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 22/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsTextViewCell.h"

@implementation IMSettingsTextViewCell

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accessoryView.frame = CGRectInset(self.bounds, 15.0f, 0.0f);
}

@end
