//
//  IMEventInputTextFieldViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 20/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEventInputTextFieldViewCell.h"
#import "IMEventInputTextField.h"

@implementation IMEventInputTextFieldViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        IMEventInputTextField *textField = [[IMEventInputTextField alloc] initWithFrame:CGRectMake(10.0f, 0.0f, self.contentView.bounds.size.width-20.0f, self.contentView.frame.size.height)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.backgroundColor = [UIColor clearColor];
        textField.adjustsFontSizeToFitWidth = NO;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.font = [IMFont standardMediumFontWithSize:16.0f];
        textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.text = @"";
        textField.inputView = nil;
        textField.inputAccessoryView = nil;
        self.control = textField;
    }
    
    return self;
}

@end
