//
//  IMNewEventInputViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMNewEventInputViewCell.h"

@implementation IMNewEventInputViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.adjustsFontSizeToFitWidth = NO;
    self.textField.keyboardType = UIKeyboardTypeAlphabet;
    self.textField.font = [IMFont standardMediumFontWithSize:16.0f];
    self.textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
}

@end
