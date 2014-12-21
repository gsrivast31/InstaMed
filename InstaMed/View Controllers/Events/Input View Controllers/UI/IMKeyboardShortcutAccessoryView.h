//
//  IMKeyboardShortcutAccessoryView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 31/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMKeyboardShortcutButton.h"

@class IMKeyboardShortcutAccessoryView;
@protocol IMKeyboardShortcutDelegate <NSObject>
- (void)keyboardShortcut:(IMKeyboardShortcutAccessoryView *)shortcutView didPressButton:(IMKeyboardShortcutButton *)button;
@end

@interface IMKeyboardShortcutAccessoryView : UIInputView <IMAutocompleteBarDelegate>
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) IMAutocompleteBar *autocompleteBar;
@property (nonatomic, assign) BOOL showingAutocompleteBar;
@property (nonatomic, assign) BOOL showingTagButton;
@property (nonatomic, weak) id<IMKeyboardShortcutDelegate, IMAutocompleteBarDelegate> delegate;

@property (nonatomic, strong) IMKeyboardShortcutButton *tagButton;
@property (nonatomic, strong) IMKeyboardShortcutButton *photoButton;
@property (nonatomic, strong) IMKeyboardShortcutButton *shareButton;
@property (nonatomic, strong) IMKeyboardShortcutButton *locationButton;
@property (nonatomic, strong) IMKeyboardShortcutButton *reminderButton;
@property (nonatomic, strong) IMKeyboardShortcutButton *deleteButton;

// Logic
- (void)showAutocompleteSuggestionsForInput:(NSString *)text;

@end


