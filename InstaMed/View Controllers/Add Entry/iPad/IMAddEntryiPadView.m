//
//  IMAddEntryiPadView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/01/2014.
//  Copyright 2014 GAURAV SRIVASTAVA
//

#import "IMAddEntryiPadView.h"
#import "IMAddEntryModaliPadButton.h"

@interface IMAddEntryiPadView ()
{
    IMAddEntryModaliPadButton *medicineButton;
    IMAddEntryModaliPadButton *readingButton;
    IMAddEntryModaliPadButton *mealButton;
    IMAddEntryModaliPadButton *activityButton;
    IMAddEntryModaliPadButton *noteButton;
}

// Logic
- (void)selectedOption:(UIButton *)sender;

@end

@implementation IMAddEntryiPadView

#pragma mark - Setup
+ (id)presentInView:(UIView *)parentView
{
    IMAddEntryiPadView *view = [[IMAddEntryiPadView alloc] initWithFrame:parentView.bounds];
    [parentView addSubview:view];
    
    return view;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tintColor = [UIColor clearColor];
        self.dynamic = NO;
        self.blurRadius = 30.0f;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 60.0f, 40.0f, 40.0f, 40.0f)];
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [closeButton setImage:[UIImage imageNamed:@"AddEntryModalCloseIconiPad"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        medicineButton = [[IMAddEntryModaliPadButton alloc] initWithFrame:CGRectZero];
        medicineButton.tag = 0;
        [medicineButton setImage:[UIImage imageNamed:@"AddEntryModalMedicineIconiPad"] forState:UIControlStateNormal];
        [medicineButton setTitle:NSLocalizedString(@"Medicine", nil) forState:UIControlStateNormal];
        [medicineButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:medicineButton];
        
        readingButton = [[IMAddEntryModaliPadButton alloc] initWithFrame:CGRectZero];
        readingButton.tag = 1;
        [readingButton setImage:[UIImage imageNamed:@"AddEntryModalBloodIconiPad"] forState:UIControlStateNormal];
        [readingButton setTitle:NSLocalizedString(@"Reading", nil) forState:UIControlStateNormal];
        [readingButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:readingButton];
        
        mealButton = [[IMAddEntryModaliPadButton alloc] initWithFrame:CGRectZero];
        mealButton.tag = 2;
        [mealButton setImage:[UIImage imageNamed:@"AddEntryModalMealIconiPad"] forState:UIControlStateNormal];
        [mealButton setTitle:NSLocalizedString(@"Food", nil) forState:UIControlStateNormal];
        [mealButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mealButton];
        
        activityButton = [[IMAddEntryModaliPadButton alloc] initWithFrame:CGRectZero];
        activityButton.tag = 3;
        [activityButton setImage:[UIImage imageNamed:@"AddEntryModalActivityIconiPad"] forState:UIControlStateNormal];
        [activityButton setTitle:NSLocalizedString(@"Activity", nil) forState:UIControlStateNormal];
        [activityButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:activityButton];
        
        noteButton = [[IMAddEntryModaliPadButton alloc] initWithFrame:CGRectZero];
        noteButton.tag = 4;
        [noteButton setImage:[UIImage imageNamed:@"AddEntryModalNoteIconiPad"] forState:UIControlStateNormal];
        [noteButton setTitle:NSLocalizedString(@"Note", nil) forState:UIControlStateNormal];
        [noteButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:noteButton];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = 75.0f;
    CGFloat totalButtonWidth = 105.0f*5.0f;
    CGFloat spacingWidth = (self.bounds.size.width-(margin*2)-totalButtonWidth)/4.0f;
    CGFloat totalWidth = totalButtonWidth + (spacingWidth*4.0f);
    CGFloat x = self.bounds.size.width/2.0f - totalWidth/2.0f;
    
    medicineButton.frame = CGRectMake(x, self.bounds.size.height/2.0f - 140.0f/2.0f, 105.0f, 140.0f);
    x += 105.0f + spacingWidth;
    readingButton.frame = CGRectMake(x, self.bounds.size.height/2.0f - 140.0f/2.0f, 105.0f, 140.0f);
    x += 105.0f + spacingWidth;
    mealButton.frame = CGRectMake(x, self.bounds.size.height/2.0f - 140.0f/2.0f, 105.0f, 140.0f);
    x += 105.0f + spacingWidth;
    activityButton.frame = CGRectMake(x, self.bounds.size.height/2.0f - 140.0f/2.0f, 105.0f, 140.0f);
    x += 105.0f + spacingWidth;
    noteButton.frame = CGRectMake(x, self.bounds.size.height/2.0f - 140.0f/2.0f, 105.0f, 140.0f);
}

#pragma mark - Logic
- (void)dismiss
{
    [self removeFromSuperview];
}

#pragma mark - UI
- (void)selectedOption:(UIButton *)sender
{
    [self.delegate addEntryModal:self didSelectEntryOption:sender.tag];
}

@end
