//
//  IMAutocompleteBar.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 27/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMHelper.h"
#import "IMAutocompleteBar.h"
#import "IMAutocompleteBarButton.h"

@interface IMAutocompleteBar ()
- (void)buttonPressed:(UIButton *)sender;
@end

@implementation IMAutocompleteBar

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 8.0f, frame.size.height)];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.directionalLockEnabled = YES;
        [self addSubview:scrollView];
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        self.suggestions = nil;
        self.shouldFetchSuggestions = YES;
        
        buttons = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Logic
- (BOOL)showSuggestionsForInput:(NSString *)input {
    // Lazy-load from our datasource if necessary
    if(self.shouldFetchSuggestions) {
        [self fetchSuggestions];
    }
    
    // Remove previous suggestions
    if([buttons count]) {
        for(UIView *view in scrollView.subviews) {
            [view removeFromSuperview];
        }
        [buttons removeAllObjects];
    }
    
    // Don't bother re-populating our options if we're not searching for anything
    if(!input) return NO;
    
    // Generate new suggestions
    NSInteger totalSuggestions = 0;
    if(input && [input length])
    {
        NSString *lowercaseInput = [input lowercaseString];

        // Generate new suggestions
        CGFloat x = 4.0f;
        CGFloat margin = 5.0f;
        for(NSString *suggestion in self.suggestions)
        {
            // Determine whether this word is valid for the input'd text
            NSString *lowercaseSuggestions = [suggestion lowercaseString];
            if([lowercaseSuggestions hasPrefix:lowercaseInput] && ![lowercaseSuggestions isEqualToString:lowercaseInput])
            {
                IMAutocompleteBarButton *button = [[IMAutocompleteBarButton alloc] initWithFrame:CGRectMake(x, scrollView.bounds.size.height/2.0f - 34.0f/2.0f, 0.0f, 34.0f)];
                [button setTitle:suggestion forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [scrollView addSubview:button];
                [buttons addObject:button];
                
                x += button.frame.size.width + margin;
                totalSuggestions ++;
            }
        }
        
        scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
        scrollView.contentSize = CGSizeMake(x, 45.0f);
    }
    return totalSuggestions ? YES : NO;
}
- (void)fetchSuggestions
{
    self.suggestions = [self.delegate suggestionsForAutocompleteBar:self];
    self.shouldFetchSuggestions = NO;
}
- (void)addTag:(UIButton *)sender
{
    [self.delegate addTagCaret];
    [self showSuggestionsForInput:@""];
}
- (void)buttonPressed:(UIButton *)sender
{
    if([self.delegate respondsToSelector:@selector(autocompleteBar:didSelectSuggestion:)])
    {
        NSString *suggestion = [sender titleForState:UIControlStateNormal];
        [self.delegate autocompleteBar:self didSelectSuggestion:suggestion];
        
        [self showSuggestionsForInput:@""];
    }
}

@end
