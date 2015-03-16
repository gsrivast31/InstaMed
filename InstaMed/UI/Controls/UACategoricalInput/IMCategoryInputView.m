//
//  IMCategoryInputView.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 02/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMCategoryInputView.h"

@interface IMCategoryInputView ()
@property (nonatomic, strong) NSArray *categories;

// Logic
- (void)didTapSelectorButton:(IMCategorySelectorButton *)button;
@end

@implementation IMCategoryInputView

#pragma mark - Setup
- (id)initWithCategories:(NSArray *)theCategories
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _categories = theCategories;
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.adjustsFontSizeToFitWidth = NO;
        _textField.font = [IMFont standardMediumFontWithSize:16.0f];
        _textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        _textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        
        _selectorButton = [[IMCategorySelectorButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 28.0f)];
        [_selectorButton addTarget:self action:@selector(didTapSelectorButton:) forControlEvents:UIControlEventTouchUpInside];
        self.selectedIndex = 0;
        
        [self addSubview:_textField];
        [self addSubview:_selectorButton];
    }
    return self;
}

#pragma mark - Logic
- (void)didTapSelectorButton:(IMCategorySelectorButton *)button
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
 
    for(NSString *category in self.categories)
    {
        [actionSheet addButtonWithTitle:category];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet setCancelButtonIndex:[self.categories count]];
    [actionSheet showInView:self];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat spacing = 10.0f;
    self.textField.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width - (self.selectorButton.bounds.size.width + spacing), self.bounds.size.height);
    self.selectorButton.frame = CGRectMake(self.textField.frame.origin.x + self.textField.frame.size.width + spacing, 0.0f, self.selectorButton.bounds.size.width, self.bounds.size.height);
}

#pragma mark - Accessors
- (void)setSelectedIndex:(NSUInteger)index
{
    _selectedIndex = index;
    
    [self.selectorButton setTitle:self.categories[index]];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != [actionSheet cancelButtonIndex])
    {
        self.selectedIndex = buttonIndex;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(categoryInputView:didSelectOption:)])
        {
            [self.delegate categoryInputView:self didSelectOption:buttonIndex];
        }
    }
}

@end
