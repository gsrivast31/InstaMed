//
//  IMKeyboardShortcutAccessoryView.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 31/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMKeyboardShortcutAccessoryView.h"

@interface IMKeyboardShortcutAccessoryView ()
@end

@implementation IMKeyboardShortcutAccessoryView

- (id)initWithFrame:(CGRect)frame {
    frame = CGRectMake(0, 0, 320.0f, 42.0f);
    self = [super initWithFrame:frame inputViewStyle:UIInputViewStyleKeyboard];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.clipsToBounds = YES;
        self.showingAutocompleteBar = YES;
        self.showingButtons = YES;
        
        CGFloat buttonX = 4.0f;
        CGFloat buttonWidth = 26.0f;
        CGFloat interButtonSpacing = 2.0f;
        
        self.tagButton = [[IMKeyboardShortcutButton alloc] initWithFrame:CGRectMake(buttonX, 0.0f, buttonWidth, 34.0f)];
        [self.tagButton setImage:[UIImage imageNamed:@"KeyboardShortcutTagIcon"] forState:UIControlStateNormal];
        [self.tagButton addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
        
        buttonX = buttonX + buttonWidth + interButtonSpacing;
        self.locationButton = [[IMKeyboardShortcutButton alloc] initWithFrame:CGRectMake(buttonX, 0.0f, buttonWidth, 34.0f)];
        [self.locationButton setImage:[UIImage imageNamed:@"KeyboardShortcutLocationIcon"] forState:UIControlStateNormal];
        [self.locationButton addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];

        buttonX = buttonX + buttonWidth + interButtonSpacing;
        self.photoButton = [[IMKeyboardShortcutButton alloc] initWithFrame:CGRectMake(buttonX, 0.0f, buttonWidth, 34.0f)];
        [self.photoButton setImage:[UIImage imageNamed:@"KeyboardShortcutPhotoIcon"] forState:UIControlStateNormal];
        [self.photoButton addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];

        buttonX = buttonX + buttonWidth + interButtonSpacing;
        self.reminderButton = [[IMKeyboardShortcutButton alloc] initWithFrame:CGRectMake(buttonX, 0.0f, buttonWidth, 34.0f)];
        [self.reminderButton setImage:[UIImage imageNamed:@"KeyboardShortcutReminderIcon"] forState:UIControlStateNormal];
        [self.reminderButton addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];

        buttonX = buttonX + buttonWidth + interButtonSpacing;
        self.deleteButton = [[IMKeyboardShortcutButton alloc] initWithFrame:CGRectMake(buttonX, 0.0f, buttonWidth, 34.0f)];
        [self.deleteButton setImage:[UIImage imageNamed:@"KeyboardShortcutDeleteIcon"] forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];

        [self setButtonStates:self.showingButtons];
        
        self.buttons = @[self.tagButton, self.locationButton, self.photoButton, self.reminderButton, self.deleteButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat centerY = CGRectGetMidY(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    
    NSUInteger totalButtons = [self.buttons count];
    CGFloat buttonWidth = self.tagButton.bounds.size.width;
    CGFloat startX = (width - totalButtons*buttonWidth - (totalButtons - 1)*2.0f)/2.0f;
    
    self.tagButton.frame = CGRectMake(startX, centerY - self.tagButton.bounds.size.height/2.0f, self.tagButton.bounds.size.width, self.tagButton.bounds.size.height);

    startX = startX + buttonWidth + 2.0f;
    self.locationButton.frame = CGRectMake(startX, centerY - self.locationButton.bounds.size.height/2.0f, self.locationButton.bounds.size.width, self.locationButton.bounds.size.height);

    startX = startX + buttonWidth + 2.0f;
    self.photoButton.frame = CGRectMake(startX, centerY - self.photoButton.bounds.size.height/2.0f, self.photoButton.bounds.size.width, self.photoButton.bounds.size.height);

    startX = startX + buttonWidth + 2.0f;
    self.reminderButton.frame = CGRectMake(startX, centerY - self.reminderButton.bounds.size.height/2.0f, self.reminderButton.bounds.size.width, self.reminderButton.bounds.size.height);

    startX = startX + buttonWidth + 2.0f;
    self.deleteButton.frame = CGRectMake(startX, centerY - self.deleteButton.bounds.size.height/2.0f, self.deleteButton.bounds.size.width, self.deleteButton.bounds.size.height);

    CGFloat x = 0.0f;
    if(self.showingButtons) {
        x = CGRectGetMaxX(self.tagButton.frame);
    }
    self.autocompleteBar.frame = CGRectMake(x, 0.0f, self.bounds.size.width - x, self.bounds.size.height);
}

#pragma mark - Logic
- (void)didPressButton:(IMKeyboardShortcutButton *)button {
    if(self.delegate) {
        [self.delegate keyboardShortcut:self didPressButton:button];
    }
}

- (void)showAutocompleteSuggestionsForInput:(NSString *)text {
    if([self.autocompleteBar showSuggestionsForInput:text]) {
        [self setShowingAutocompleteBar:YES];
    } else {
        [self setShowingAutocompleteBar:NO];
    }
}

#pragma mark - Getters/setters
-(void)setShowingButtons:(BOOL)state {
    [self setButtonStates:state];
    _showingButtons = state;
    
    [self setNeedsLayout];
}

- (void)setShowingAutocompleteBar:(BOOL)state {
    self.autocompleteBar.hidden = !state;
    _showingAutocompleteBar = state;
    
    self.showingButtons = !state;
}

- (void)setButtons:(NSArray *)newButtons {
    _buttons = newButtons;
    for(UIButton *button in self.buttons) {
        if(![button superview]) {
            [self addSubview:button];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setButtonStates:(BOOL)state {
    self.tagButton.hidden = !state;
    self.photoButton.hidden = !state;
    self.locationButton.hidden = !state;
    self.reminderButton.hidden = !state;
    self.deleteButton.hidden = !state;
}

- (IMAutocompleteBar *)autocompleteBar {
    if(!_autocompleteBar) {
        _autocompleteBar = [[IMAutocompleteBar alloc] initWithFrame:self.bounds];
        _autocompleteBar.delegate = self;
        _autocompleteBar.hidden = YES;
        
        [self addSubview:_autocompleteBar];
    }
    
    return _autocompleteBar;
}

#pragma mark - IMAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(IMAutocompleteBar *)theAutocompleteBar {
    if(self.delegate) {
        return [self.delegate suggestionsForAutocompleteBar:theAutocompleteBar];
    }
    
    return nil;
}

- (void)autocompleteBar:(IMAutocompleteBar *)autocompleteBar didSelectSuggestion:(NSString *)suggestion {
    if(self.delegate) [self.delegate autocompleteBar:autocompleteBar didSelectSuggestion:suggestion];
}

- (void)addTagCaret {
    if(self.delegate && [self.delegate respondsToSelector:@selector(addTagCaret)]) {
        [self.delegate addTagCaret];
    }
}

@end
