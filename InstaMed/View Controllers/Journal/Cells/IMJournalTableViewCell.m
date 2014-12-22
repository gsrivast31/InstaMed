//
//  IMJournalTableViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMJournalTableViewCell.h"

@interface IMJournalTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *glucoseDeviationView;
@property (weak, nonatomic) IBOutlet UIView *avgBloodGlucoseView;
@property (weak, nonatomic) IBOutlet UIView *lowestGlucoseView;
@property (weak, nonatomic) IBOutlet UIView *highestGlucoseView;
@property (weak, nonatomic) IBOutlet UIView *totalGramsView;
@property (weak, nonatomic) IBOutlet UIView *totalMinutesView;

@property (weak, nonatomic) IBOutlet UILabel *glucoseDeviationLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgBloodGlucoseLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowestReadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *highestGlucoseLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMinutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalGramsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *glucoseDeviationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lowestReadingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *highestReadingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avgBloodGlucoseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *totalGramsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *totalMinutesImageView;

@end

@implementation IMJournalTableViewCell

- (void)setDeviationValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        //deviationImageView.image = [UIImage imageNamed:@"JournalIconDeviation"];
        self.glucoseDeviationLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        self.glucoseDeviationLabel.text = [valueFormatter stringFromNumber:value];
        //deviationDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    } else {
        //deviationImageView.image = [UIImage imageNamed:@"JournalIconDeviationInactive"];
        self.glucoseDeviationLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        self.glucoseDeviationLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        self.glucoseDeviationLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        //deviationDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
    self.glucoseDeviationView.layer.cornerRadius = CGRectGetWidth(self.glucoseDeviationView.frame) / 2.0f;
}

- (void)setAverageGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        //glucoseImageView.image = [UIImage imageNamed:@"JournalIconBlood"];
        self.avgBloodGlucoseLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        self.avgBloodGlucoseLabel.text = [valueFormatter stringFromNumber:value];
        //glucoseDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    } else {
        //glucoseImageView.image = [UIImage imageNamed:@"JournalIconBloodInactive"];
        self.avgBloodGlucoseLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        self.avgBloodGlucoseLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        self.avgBloodGlucoseLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        //glucoseDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
    self.avgBloodGlucoseView.layer.cornerRadius = CGRectGetWidth(self.avgBloodGlucoseView.frame) / 2.0f;
}

- (void)setLowGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        self.lowestReadingLabel.text = [valueFormatter stringFromNumber:value];
        //lowGlucoseDetailLabel.hidden = NO;
        //lowGlucoseImageView.hidden = NO;
    } else {
        //lowGlucoseDetailLabel.hidden = YES;
        //lowGlucoseImageView.hidden = YES;
    }
    self.lowestGlucoseView.layer.cornerRadius = CGRectGetWidth(self.lowestGlucoseView.frame) / 2.0f;

}

- (void)setHighGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        self.highestGlucoseLabel.text = [valueFormatter stringFromNumber:value];
        //self.highGlucoseDetailLabel.hidden = NO;
        //self.highGlucoseImageView.hidden = NO;
    } else {
        //self.highGlucoseDetailLabel.hidden = YES;
        //self.highGlucoseImageView.hidden = YES;
    }
    self.highestGlucoseView.layer.cornerRadius = CGRectGetWidth(self.highestGlucoseView.frame) / 2.0f;

}

- (void)setActivityValue:(NSInteger)value {
    if(value > 0) {
        //activityImageView.image = [UIImage imageNamed:@"JournalIconActivity"];
        self.totalMinutesLabel.textColor = [UIColor colorWithRed:113.0f/255.0f green:185.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        //activityDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        self.totalMinutesLabel.text = [IMHelper formatMinutes:value];
    } else {
        //activityImageView.image = [UIImage imageNamed:@"JournalIconActivityInactive"];
        self.totalMinutesLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        self.totalMinutesLabel.text = @"00:00";
        self.totalMinutesLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
       // activityDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
    self.totalMinutesView.layer.cornerRadius = CGRectGetWidth(self.totalMinutesView.frame) / 2.0f;

}

- (void)setMealValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter {
    if([value doubleValue] > 0) {
        //mealImageView.image = [UIImage imageNamed:@"JournalIconCarbs"];
        self.totalGramsLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:196.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
        //mealDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        self.totalGramsLabel.text = [valueFormatter stringFromNumber:value];
    } else {
        //mealImageView.image = [UIImage imageNamed:@"JournalIconCarbsInactive"];
        self.totalGramsLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        //mealDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        self.totalGramsLabel.text = @"0";
    }
    self.totalGramsView.layer.cornerRadius = CGRectGetWidth(self.totalGramsView.frame) / 2.0f;

}

- (void)configureCell:(NSDictionary*)stats {
    /*self.glucoseDeviationView.backgroundColor = [UIColor clearColor];
    self.avgBloodGlucoseView.backgroundColor = [UIColor clearColor];
    self.lowestGlucoseView.backgroundColor = [UIColor clearColor];
    self.highestGlucoseView.backgroundColor = [UIColor clearColor];
    self.totalGramsView.backgroundColor = [UIColor clearColor];
    self.totalMinutesView.backgroundColor = [UIColor clearColor];*/

    NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
    NSNumberFormatter *glucoseFormatter = [IMHelper glucoseNumberFormatter];
    
    NSInteger totalGrams = [[stats valueForKey:@"total_grams"] integerValue];
    NSInteger totalReadings = [[stats valueForKey:@"total_readings"] integerValue];
    NSInteger totalMinutes = [[stats objectForKey:@"total_minutes"] integerValue];
    double readingsAvg = [[stats valueForKey:@"readings_avg"] doubleValue];
    double readingsDeviation = [[stats valueForKey:@"readings_deviation"] doubleValue];
    double lowGlucose = [[stats valueForKey:@"lowest_reading"] doubleValue];
    double highGlucose = [[stats valueForKey:@"highest_reading"] doubleValue];
    
    if(totalReadings) {
        [self setAverageGlucoseValue:[NSNumber numberWithDouble:readingsAvg] withFormatter:glucoseFormatter];
        [self setDeviationValue:[NSNumber numberWithDouble:readingsDeviation] withFormatter:glucoseFormatter];
    } else {
        [self setAverageGlucoseValue:[NSNumber numberWithDouble:0.0] withFormatter:glucoseFormatter];
        [self setDeviationValue:[NSNumber numberWithDouble:0.0] withFormatter:glucoseFormatter];
    }
    [self setMealValue:[NSNumber numberWithDouble:totalGrams] withFormatter:valueFormatter];
    [self setActivityValue:totalMinutes];
    [self setLowGlucoseValue:[NSNumber numberWithDouble:lowGlucose] withFormatter:glucoseFormatter];
    [self setHighGlucoseValue:[NSNumber numberWithDouble:highGlucose] withFormatter:glucoseFormatter];
    //cell.monthLabel.text = key;
}

@end
