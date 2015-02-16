//
//  IMJournalMonthViewCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 30/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMJournalMonthViewCell : IMGenericTableViewCell
@property (nonatomic, strong) UILabel *monthLabel;

// Accessors
- (void)setBGDeviationValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setAverageGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setLowGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setHighGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;

- (void)setChDeviationValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setAverageCholesterolValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setLowCholesterolValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setHighCholesterolValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;

- (void)setBPState:(BOOL)state;
- (void)setLowBPValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setHighBPValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;

- (void)setWeightState:(BOOL)state;
- (void)setLowWeightValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;
- (void)setHighWeightValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;

- (void)setActivityValue:(NSInteger)value;
- (void)setMealValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter;

@end