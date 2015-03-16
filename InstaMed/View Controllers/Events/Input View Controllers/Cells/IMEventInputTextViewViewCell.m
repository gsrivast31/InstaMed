//
//  IMEventInputTextViewViewCell.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 20/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEventInputTextViewViewCell.h"
#import "IMEventNotesTextView.h"

@implementation IMEventInputTextViewViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        IMEventNotesTextView *textView = [[IMEventNotesTextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.scrollEnabled = NO;
        textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textView.autocorrectionType = UITextAutocorrectionTypeYes;
        textView.font = [IMFont standardMediumFontWithSize:16.0f];
        textView.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        textView.text = @"";
        textView.inputView = nil;
        textView.inputAccessoryView = nil;
        
        self.control = textView;
    }
    
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.control.frame = CGRectMake(78.0f, 0.0f, self.frame.size.width-88.0f, self.frame.size.height);
}

@end
