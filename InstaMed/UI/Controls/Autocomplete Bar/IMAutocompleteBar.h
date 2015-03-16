//
//  IMAutocompleteBar.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 27/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMAppDelegate.h"

@class IMAutocompleteBar;
@protocol IMAutocompleteBarDelegate <NSObject>

@required
- (NSArray *)suggestionsForAutocompleteBar:(IMAutocompleteBar *)autocompleteBar;
- (void)autocompleteBar:(IMAutocompleteBar *)autocompleteBar didSelectSuggestion:(NSString *)suggestion;

@optional
- (void)addTagCaret;

@end

@interface IMAutocompleteBar : UIView
{
    UIScrollView *scrollView;
    NSMutableArray *buttons;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *suggestions;
@property (nonatomic, assign) BOOL shouldFetchSuggestions;

// Setup
- (id)initWithFrame:(CGRect)frame;

// Logic
- (void)fetchSuggestions;
- (BOOL)showSuggestionsForInput:(NSString *)input;

@end
