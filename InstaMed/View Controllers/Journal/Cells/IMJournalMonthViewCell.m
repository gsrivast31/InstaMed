//
//  IMJournalMonthViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 30/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMJournalMonthViewCell.h"

@interface IMJournalMonthViewCell ()
{
    //Meal
    UIImageView *mealImageView;
    UILabel *mealLabel;
    UILabel *mealDetailLabel;

    //Activity
    UIImageView *activityImageView;
    UILabel *activityLabel;
    UILabel *activityDetailLabel;

    //Blood Glucose
    UIImageView *bgDeviationImageView;
    UILabel *bgDeviationLabel;
    UILabel *bgDeviationDetailLabel;

    UIImageView *glucoseImageView;
    UILabel *glucoseLabel;
    UILabel *glucoseDetailLabel;

    UIImageView *lowGlucoseImageView;
    UIImageView *highGlucoseImageView;
    UILabel *lowGlucoseDetailLabel;
    UILabel *highGlucoseDetailLabel;

    //Cholesterol
    UIImageView *chDeviationImageView;
    UILabel *chDeviationLabel;
    UILabel *chDeviationDetailLabel;
    
    UIImageView *cholesterolImageView;
    UILabel *cholesterolLabel;
    UILabel *cholesterolDetailLabel;
    
    UIImageView *lowCholesterolImageView;
    UIImageView *highCholesterolImageView;
    UILabel *lowCholesterolDetailLabel;
    UILabel *highCholesterolDetailLabel;

    //Blood Pressure
    UIImageView *bpImageView;
    UIImageView *lowBPImageView;
    UIImageView *highBPImageView;
    UILabel *lowBPDetailLabel;
    UILabel *highBPDetailLabel;
    UILabel *lowBPLabel;
    UILabel *highBPLabel;

    //Weight
    UIImageView *weightImageView;
    UIImageView *lowWeightImageView;
    UIImageView *highWeightImageView;
    UILabel *lowWeightDetailLabel;
    UILabel *highWeightDetailLabel;
    UILabel *lowWeightLabel;
    UILabel *highWeightLabel;

    UIView *cellBottomBorder;
}
@end

@implementation IMJournalMonthViewCell
@synthesize monthLabel = _monthLabel;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView *cellTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.5f)];
        cellTopBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cellTopBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:cellTopBorder];
        
        cellBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height-0.5f, self.frame.size.width, 0.5f)];
        cellBottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cellBottomBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:cellBottomBorder];
        
        // Header/month label
        _monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 1.0f, self.frame.size.width-40.0f, 44.0f)];
        _monthLabel.backgroundColor = [UIColor whiteColor];
        _monthLabel.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        _monthLabel.font = [IMFont standardRegularFontWithSize:21.0f];
        _monthLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_monthLabel];
        
        UIView *monthBorder = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 44.0f, self.frame.size.width-20.0f, 0.5f)];
        monthBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        monthBorder.backgroundColor = [UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:monthBorder];
        
        UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconChevron"]];
        chevron.frame = CGRectMake(self.bounds.size.width - 30.0f, 12.0f, 13.0f, 20.0f);
        chevron.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:chevron];
        
        CGFloat y = 46.0f;
        
        // Glucose
        [self addBloodGlucoseRow:y];
        UIView *horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        y += 56.0f;
        
        // Glucose Deviation
        [self addGlucoseDeviationRow:y];
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        y += 56.0f;

        // Cholesterol
        [self addCholesterolRow:y];
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        y += 56.0f;

        // Cholesterol Deviation
        [self addCholesterolDeviationRow:y];
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        y += 56.0f;

        // Blood Pressure
        [self addBloodPressureRow:y];
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        y += 56.0f;

        // Weight
        [self addWeightRow:y];
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        y += 56.0f;
        
        // Activity
        [self addActivityRow:y];
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        y += 56.0f;
        
        // Meal
        [self addMealRow:y];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    cellBottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-0.5f, self.frame.size.width, 0.5f);
}

- (void)addBloodGlucoseRow:(CGFloat)y {
    glucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBlood.png"]];
    glucoseImageView.frame = CGRectMake(20.0f, y + 10.0f, glucoseImageView.frame.size.width, glucoseImageView.frame.size.height);
    [self.contentView addSubview:glucoseImageView];
    
    glucoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
    glucoseLabel.backgroundColor = [UIColor whiteColor];
    glucoseLabel.text = @"0.0";
    glucoseLabel.font = [IMFont standardRegularFontWithSize:18.0f];
    glucoseLabel.textAlignment = NSTextAlignmentLeft;
    glucoseLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    glucoseLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:glucoseLabel];
    
    glucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
    glucoseDetailLabel.backgroundColor = [UIColor whiteColor];
    glucoseDetailLabel.text = [NSLocalizedString(@"Avg. Blood Glucose", @"Label for average blood glucose reading") uppercaseString];
    glucoseDetailLabel.font = [IMFont standardMediumFontWithSize:12.0f];
    glucoseDetailLabel.textAlignment = NSTextAlignmentLeft;
    glucoseDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    glucoseDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:glucoseDetailLabel];
    
    highGlucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodHigh"]];
    highGlucoseImageView.frame = CGRectMake(self.bounds.size.width - 87.0f, 53.0f, 15.0f, 15.0f);
    [self.contentView addSubview:highGlucoseImageView];
    
    highGlucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 67.0f, 53.0f, 67.0f, 16.0f)];
    highGlucoseDetailLabel.backgroundColor = [UIColor whiteColor];
    highGlucoseDetailLabel.text = @"0";
    highGlucoseDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    highGlucoseDetailLabel.textAlignment = NSTextAlignmentLeft;
    highGlucoseDetailLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
    highGlucoseDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:highGlucoseDetailLabel];
    
    lowGlucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodLow"]];
    lowGlucoseImageView.frame = CGRectMake(self.bounds.size.width - 87.0f, 75.0f, 15.0f, 15.0f);
    [self.contentView addSubview:lowGlucoseImageView];
    
    lowGlucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 67.0f, 75.0f, 67.0f, 16.0f)];
    lowGlucoseDetailLabel.backgroundColor = [UIColor whiteColor];
    lowGlucoseDetailLabel.text = @"0";
    lowGlucoseDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    lowGlucoseDetailLabel.textAlignment = NSTextAlignmentLeft;
    lowGlucoseDetailLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    lowGlucoseDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:lowGlucoseDetailLabel];
}

- (void)addCholesterolRow:(CGFloat)y {
    cholesterolImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBlood.png"]];
    cholesterolImageView.frame = CGRectMake(20.0f, y + 10.0f, cholesterolImageView.frame.size.width, cholesterolImageView.frame.size.height);
    [self.contentView addSubview:cholesterolImageView];
    
    cholesterolLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
    cholesterolLabel.backgroundColor = [UIColor whiteColor];
    cholesterolLabel.text = @"0.0";
    cholesterolLabel.font = [IMFont standardRegularFontWithSize:18.0f];
    cholesterolLabel.textAlignment = NSTextAlignmentLeft;
    cholesterolLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    cholesterolLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:cholesterolLabel];
    
    cholesterolDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
    cholesterolDetailLabel.backgroundColor = [UIColor whiteColor];
    cholesterolDetailLabel.text = [NSLocalizedString(@"Avg. Cholesterol", @"Label for average cholesterol reading") uppercaseString];
    cholesterolDetailLabel.font = [IMFont standardMediumFontWithSize:12.0f];
    cholesterolDetailLabel.textAlignment = NSTextAlignmentLeft;
    cholesterolDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    cholesterolDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:cholesterolDetailLabel];
    
    highCholesterolImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodHigh"]];
    highCholesterolImageView.frame = CGRectMake(self.bounds.size.width - 87.0f, 53.0f, 15.0f, 15.0f);
    [self.contentView addSubview:highCholesterolImageView];
    
    highCholesterolDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 67.0f, 53.0f, 67.0f, 16.0f)];
    highCholesterolDetailLabel.backgroundColor = [UIColor whiteColor];
    highCholesterolDetailLabel.text = @"0";
    highCholesterolDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    highCholesterolDetailLabel.textAlignment = NSTextAlignmentLeft;
    highCholesterolDetailLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
    highCholesterolDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:highCholesterolDetailLabel];
    
    lowCholesterolImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodLow"]];
    lowCholesterolImageView.frame = CGRectMake(self.bounds.size.width - 87.0f, 75.0f, 15.0f, 15.0f);
    [self.contentView addSubview:lowCholesterolImageView];
    
    lowCholesterolDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 67.0f, 75.0f, 67.0f, 16.0f)];
    lowCholesterolDetailLabel.backgroundColor = [UIColor whiteColor];
    lowCholesterolDetailLabel.text = @"0";
    lowCholesterolDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    lowCholesterolDetailLabel.textAlignment = NSTextAlignmentLeft;
    lowCholesterolDetailLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    lowCholesterolDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:lowCholesterolDetailLabel];
}

- (void)addBloodPressureRow:(CGFloat)y {
    bpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBlood.png"]];
    bpImageView.frame = CGRectMake(20.0f, y + 10.0f, bpImageView.frame.size.width, bpImageView.frame.size.height);
    [self.contentView addSubview:bpImageView];
    
    highBPImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodHigh"]];
    highBPImageView.frame = CGRectMake(72.0f, y + 7.0f, 15.0f, 15.0f);
    [self.contentView addSubview:highBPImageView];
    
    highBPDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(92.0f, y + 7.0f, 25.0f, 16.0f)];
    highBPDetailLabel.backgroundColor = [UIColor whiteColor];
    highBPDetailLabel.text = @"0";
    highBPDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    highBPDetailLabel.textAlignment = NSTextAlignmentLeft;
    highBPDetailLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
    highBPDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:highBPDetailLabel];
    
    lowBPImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodLow"]];
    lowBPImageView.frame = CGRectMake(72.0f, y + 29.0f, 15.0f, 15.0f);
    [self.contentView addSubview:lowBPImageView];
    
    lowBPDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(92.0f, y + 29.0f, 25.0f, 16.0f)];
    lowBPDetailLabel.backgroundColor = [UIColor whiteColor];
    lowBPDetailLabel.text = @"0";
    lowBPDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    lowBPDetailLabel.textAlignment = NSTextAlignmentLeft;
    lowBPDetailLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    lowBPDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:lowBPDetailLabel];
    
    highBPLabel = [[UILabel alloc] initWithFrame:CGRectMake(122.0f, y + 7.0f, self.bounds.size.width-92.0f, 16.0f)];
    highBPLabel.backgroundColor = [UIColor whiteColor];
    highBPLabel.text = [NSLocalizedString(@"Highest BP Reading", @"Label for highest blood pressure reading") uppercaseString];
    highBPLabel.font = [IMFont standardMediumFontWithSize:13.0f];
    highBPLabel.textAlignment = NSTextAlignmentLeft;
    highBPLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    highBPLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:highBPLabel];

    lowBPLabel = [[UILabel alloc] initWithFrame:CGRectMake(122.0f, y + 29.0f, self.bounds.size.width-92.0f, 16.0f)];
    lowBPLabel.backgroundColor = [UIColor whiteColor];
    lowBPLabel.text = [NSLocalizedString(@"Lowest BP Reading", @"Label for lowest blood pressure reading") uppercaseString];
    lowBPLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    lowBPLabel.textAlignment = NSTextAlignmentLeft;
    lowBPLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    lowBPLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:lowBPLabel];
}

- (void)addWeightRow:(CGFloat)y {
    weightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBlood.png"]];
    weightImageView.frame = CGRectMake(20.0f, y + 10.0f, weightImageView.frame.size.width, weightImageView.frame.size.height);
    [self.contentView addSubview:weightImageView];
    
    highWeightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodHigh"]];
    highWeightImageView.frame = CGRectMake(72.0f, y + 7.0f, 15.0f, 15.0f);
    [self.contentView addSubview:highWeightImageView];
    
    highWeightDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(92.0f, y + 7.0f, 25.0f, 16.0f)];
    highWeightDetailLabel.backgroundColor = [UIColor whiteColor];
    highWeightDetailLabel.text = @"0";
    highWeightDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    highWeightDetailLabel.textAlignment = NSTextAlignmentLeft;
    highWeightDetailLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
    highWeightDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:highWeightDetailLabel];
    
    lowWeightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodLow"]];
    lowWeightImageView.frame = CGRectMake(72.0f, y + 29.0f, 15.0f, 15.0f);
    [self.contentView addSubview:lowWeightImageView];
    
    lowWeightDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(92.0f, y + 29.0f, 25.0f, 16.0f)];
    lowWeightDetailLabel.backgroundColor = [UIColor whiteColor];
    lowWeightDetailLabel.text = @"0";
    lowWeightDetailLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    lowWeightDetailLabel.textAlignment = NSTextAlignmentLeft;
    lowWeightDetailLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    lowWeightDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:lowWeightDetailLabel];
    
    highWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(122.0f, y + 7.0f, self.bounds.size.width-92.0f, 16.0f)];
    highWeightLabel.backgroundColor = [UIColor whiteColor];
    highWeightLabel.text = [NSLocalizedString(@"Highest Weight", @"Label for highest weight") uppercaseString];
    highWeightLabel.font = [IMFont standardMediumFontWithSize:13.0f];
    highWeightLabel.textAlignment = NSTextAlignmentLeft;
    highWeightLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    highWeightLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:highWeightLabel];
    
    lowWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(122.0f, y + 29.0f, self.bounds.size.width-92.0f, 16.0f)];
    lowWeightLabel.backgroundColor = [UIColor whiteColor];
    lowWeightLabel.text = [NSLocalizedString(@"Lowest Weight", @"Label for lowest weight") uppercaseString];
    lowWeightLabel.font = [IMFont standardRegularFontWithSize:13.0f];
    lowWeightLabel.textAlignment = NSTextAlignmentLeft;
    lowWeightLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    lowWeightLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:lowWeightLabel];
}

- (void)addActivityRow:(CGFloat)y {
    activityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconActivity.png"]];
    activityImageView.frame = CGRectMake(20.0f, y + 10.0f, activityImageView.frame.size.width, activityImageView.frame.size.height);
    [self.contentView addSubview:activityImageView];
    
    activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
    activityLabel.backgroundColor = [UIColor whiteColor];
    activityLabel.text = @"0";
    activityLabel.font = [IMFont standardRegularFontWithSize:18.0f];
    activityLabel.textAlignment = NSTextAlignmentLeft;
    activityLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    activityLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:activityLabel];
    
    activityDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
    activityDetailLabel.backgroundColor = [UIColor whiteColor];
    activityDetailLabel.text = [NSLocalizedString(@"Activity", @"Activity (physical exercise)") uppercaseString];
    activityDetailLabel.font = [IMFont standardMediumFontWithSize:12.0f];
    activityDetailLabel.textAlignment = NSTextAlignmentLeft;
    activityDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    activityDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:activityDetailLabel];
}

- (void)addMealRow:(CGFloat)y {
    mealImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconCarbs.png"]];
    mealImageView.frame = CGRectMake(20.0f, y + 10.0f, mealImageView.frame.size.width, mealImageView.frame.size.height);
    [self.contentView addSubview:mealImageView];
    
    mealLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
    mealLabel.backgroundColor = [UIColor whiteColor];
    mealLabel.text = @"0";
    mealLabel.font = [IMFont standardRegularFontWithSize:18.0f];
    mealLabel.textAlignment = NSTextAlignmentLeft;
    mealLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    mealLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:mealLabel];
    
    mealDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
    mealDetailLabel.backgroundColor = [UIColor whiteColor];
    mealDetailLabel.text = [NSLocalizedString(@"Grams", @"Unit of measurement") uppercaseString];
    mealDetailLabel.font = [IMFont standardMediumFontWithSize:12.0f];
    mealDetailLabel.textAlignment = NSTextAlignmentLeft;
    mealDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    mealDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:mealDetailLabel];
}

- (void)addGlucoseDeviationRow:(CGFloat)y {
    bgDeviationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconDeviation.png"]];
    bgDeviationImageView.frame = CGRectMake(20.0f, y + 10.0f, bgDeviationImageView.frame.size.width, bgDeviationImageView.frame.size.height);
    [self.contentView addSubview:bgDeviationImageView];
    
    bgDeviationLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
    bgDeviationLabel.backgroundColor = [UIColor whiteColor];
    bgDeviationLabel.text = @"0.0";
    bgDeviationLabel.font = [IMFont standardRegularFontWithSize:18.0f];
    bgDeviationLabel.textAlignment = NSTextAlignmentLeft;
    bgDeviationLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    bgDeviationLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:bgDeviationLabel];
    
    bgDeviationDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
    bgDeviationDetailLabel.backgroundColor = [UIColor whiteColor];
    bgDeviationDetailLabel.text = [NSLocalizedString(@"Blood Glucose Deviation", @"Label for the statistical deviation in blood glucose values") uppercaseString];
    bgDeviationDetailLabel.font = [IMFont standardMediumFontWithSize:12.0f];
    bgDeviationDetailLabel.textAlignment = NSTextAlignmentLeft;
    bgDeviationDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    bgDeviationDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:bgDeviationDetailLabel];
}

- (void)addCholesterolDeviationRow:(CGFloat)y {
    chDeviationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconDeviation.png"]];
    chDeviationImageView.frame = CGRectMake(20.0f, y + 10.0f, chDeviationImageView.frame.size.width, chDeviationImageView.frame.size.height);
    [self.contentView addSubview:chDeviationImageView];
    
    chDeviationLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
    chDeviationLabel.backgroundColor = [UIColor whiteColor];
    chDeviationLabel.text = @"0.0";
    chDeviationLabel.font = [IMFont standardRegularFontWithSize:18.0f];
    chDeviationLabel.textAlignment = NSTextAlignmentLeft;
    chDeviationLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    chDeviationLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:chDeviationLabel];
    
    chDeviationDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
    chDeviationDetailLabel.backgroundColor = [UIColor whiteColor];
    chDeviationDetailLabel.text = [NSLocalizedString(@"Cholesterol Deviation", @"Label for the statistical deviation in cholesterol values") uppercaseString];
    chDeviationDetailLabel.font = [IMFont standardMediumFontWithSize:12.0f];
    chDeviationDetailLabel.textAlignment = NSTextAlignmentLeft;
    chDeviationDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    chDeviationDetailLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:chDeviationDetailLabel];
}

#pragma mark - Accessors
- (void)setBGDeviationValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        bgDeviationImageView.image = [UIImage imageNamed:@"JournalIconDeviation"];
        bgDeviationLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        bgDeviationLabel.text = [valueFormatter stringFromNumber:value];
        bgDeviationDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    } else {
        bgDeviationImageView.image = [UIImage imageNamed:@"JournalIconDeviationInactive"];
        bgDeviationLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        bgDeviationLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        bgDeviationLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        bgDeviationDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}

- (void)setAverageGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        glucoseImageView.image = [UIImage imageNamed:@"JournalIconBlood"];
        glucoseLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        glucoseLabel.text = [valueFormatter stringFromNumber:value];
        glucoseDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    } else {
        glucoseImageView.image = [UIImage imageNamed:@"JournalIconBloodInactive"];
        glucoseLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        glucoseLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        glucoseLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        glucoseDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}

- (void)setLowGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        lowGlucoseDetailLabel.text = [valueFormatter stringFromNumber:value];
        lowGlucoseDetailLabel.hidden = NO;
        lowGlucoseImageView.hidden = NO;
    } else {
        lowGlucoseDetailLabel.hidden = YES;
        lowGlucoseImageView.hidden = YES;
    }
}

- (void)setHighGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        highGlucoseDetailLabel.text = [valueFormatter stringFromNumber:value];
        highGlucoseDetailLabel.hidden = NO;
        highGlucoseImageView.hidden = NO;
    } else {
        highGlucoseDetailLabel.hidden = YES;
        highGlucoseImageView.hidden = YES;
    }
}

- (void)setChDeviationValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        chDeviationImageView.image = [UIImage imageNamed:@"JournalIconDeviation"];
        chDeviationLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        chDeviationLabel.text = [valueFormatter stringFromNumber:value];
        chDeviationDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    } else {
        chDeviationImageView.image = [UIImage imageNamed:@"JournalIconDeviationInactive"];
        chDeviationLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        chDeviationLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        chDeviationLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        chDeviationDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}

- (void)setAverageCholesterolValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        cholesterolImageView.image = [UIImage imageNamed:@"JournalIconBlood"];
        cholesterolLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        cholesterolLabel.text = [valueFormatter stringFromNumber:value];
        cholesterolDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    } else {
        cholesterolImageView.image = [UIImage imageNamed:@"JournalIconBloodInactive"];
        cholesterolLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        cholesterolLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        cholesterolLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        cholesterolDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}

- (void)setLowCholesterolValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        lowCholesterolDetailLabel.text = [valueFormatter stringFromNumber:value];
        lowCholesterolDetailLabel.hidden = NO;
        lowCholesterolImageView.hidden = NO;
    } else {
        lowCholesterolDetailLabel.hidden = YES;
        lowCholesterolImageView.hidden = YES;
    }
}

- (void)setHighCholesterolValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        highCholesterolDetailLabel.text = [valueFormatter stringFromNumber:value];
        highCholesterolDetailLabel.hidden = NO;
        highCholesterolImageView.hidden = NO;
    } else {
        highCholesterolDetailLabel.hidden = YES;
        highCholesterolImageView.hidden = YES;
    }
}

- (void)setLowBPValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        lowBPDetailLabel.text = [valueFormatter stringFromNumber:value];
        lowBPDetailLabel.hidden = NO;
        lowBPImageView.hidden = NO;
    } else {
        lowBPDetailLabel.hidden = YES;
        lowBPImageView.hidden = YES;
    }
}

- (void)setHighBPValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        highBPDetailLabel.text = [valueFormatter stringFromNumber:value];
        highBPDetailLabel.hidden = NO;
        highBPImageView.hidden = NO;
    } else {
        highBPDetailLabel.hidden = YES;
        highBPImageView.hidden = YES;
    }
}

- (void)setLowWeightValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        lowWeightDetailLabel.text = [valueFormatter stringFromNumber:value];
        lowWeightDetailLabel.hidden = NO;
        lowWeightImageView.hidden = NO;
    } else {
        lowWeightDetailLabel.hidden = YES;
        lowWeightImageView.hidden = YES;
    }
}

- (void)setHighWeightValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        highGlucoseDetailLabel.text = [valueFormatter stringFromNumber:value];
        highGlucoseDetailLabel.hidden = NO;
        highGlucoseImageView.hidden = NO;
    } else {
        highGlucoseDetailLabel.hidden = YES;
        highGlucoseImageView.hidden = YES;
    }
}

- (void)setActivityValue:(NSInteger)value {
    if(value > 0) {
        activityImageView.image = [UIImage imageNamed:@"JournalIconActivity"];
        activityLabel.textColor = [UIColor colorWithRed:113.0f/255.0f green:185.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        activityDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        activityLabel.text = [IMHelper formatMinutes:value];
    } else {
        activityImageView.image = [UIImage imageNamed:@"JournalIconActivityInactive"];
        activityLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        activityLabel.text = @"00:00";
        activityLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        activityDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}

- (void)setMealValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        mealImageView.image = [UIImage imageNamed:@"JournalIconCarbs"];
        mealLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:196.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
        mealDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        mealLabel.text = [valueFormatter stringFromNumber:value];
    } else {
        mealImageView.image = [UIImage imageNamed:@"JournalIconCarbsInactive"];
        mealLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        mealDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        mealLabel.text = @"0";
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    mealImageView.tintColor = [UIColor redColor];
}
@end
