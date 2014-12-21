//
//  IMDayRecordTableViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMDayRecordTableViewCell.h"
#import "IMEvent.h"
#import "IMReading.h"
#import "IMActivity.h"
#import "IMMeal.h"
#import "IMMedicine.h"
#import "IMEventController.h"
#import "IMMediaController.h"

@interface IMDayRecordTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;
@property (weak, nonatomic) IBOutlet UILabel *recordTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UIView *topLineView;

@end

@implementation IMDayRecordTableViewCell

+ (CGFloat)heightForEntry {
/*    const CGFloat topMargin = 35.0f;
    const CGFloat bottomMargin = 80.0f;
    const CGFloat minHeight = 60.0f;
    
    if () {
        <#statements#>
    }
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGRect boundingBox = [entry.body boundingRectWithSize:CGSizeMake(202, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:nil];
    
    return MAX(minHeight, CGRectGetHeight(boundingBox) + topMargin + bottomMargin);
 */
    return 60.0f;
}

- (void)configureCellForEntry:(NSManagedObject*)object hasTop:(BOOL)top hasBottom:(BOOL)bottom withDate:(NSDate*)date withAlpha:(CGFloat)alpha {
    
    NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
    NSNumberFormatter *glucoseFormatter = [IMHelper glucoseNumberFormatter];
    
    self.recordImageView.alpha = alpha;
    self.recordTimeLabel.alpha = alpha;
    self.recordTitleLabel.alpha = alpha;
    self.recordValueLabel.alpha = alpha;
    
    if([object isKindOfClass:[IMMeal class]]){
        
        IMMeal *meal = (IMMeal *)object;
        self.recordTitleLabel.text = [meal name];
        self.recordValueLabel.text = [valueFormatter stringFromNumber:[meal grams]];
        self.recordValueLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        self.recordImageView.image = [UIImage imageNamed:@"AddEntryMealBubble"];
        self.recordImageView.highlightedImage = [UIImage imageNamed:@"AddEntryMealBubble"];
        
    } else if([object isKindOfClass:[IMReading class]]) {
        
        IMReading *reading = (IMReading *)object;
        
        self.recordTitleLabel.text = NSLocalizedString(@"Blood glucose level", nil);
        self.recordValueLabel.text = [glucoseFormatter stringFromNumber:[reading value]];
        self.recordImageView.image = [UIImage imageNamed:@"AddEntryBloodBubble"];
        self.recordImageView.highlightedImage = [UIImage imageNamed:@"AddEntryBloodBubble"];
        
        if(![IMHelper isBGLevelSafe:[[reading value] doubleValue]]) {
            self.recordValueLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        } else {
            self.recordValueLabel.textColor = [UIColor colorWithRed:24.0f/255.0f green:197.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
        }
        
    } else if([object isKindOfClass:[IMMedicine class]]) {
        
        IMMedicine *medicine = (IMMedicine *)object;
        
        self.recordValueLabel.text = [valueFormatter stringFromNumber:[medicine amount]];
        self.recordValueLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        self.recordImageView.image = [UIImage imageNamed:@"AddEntryMedicineBubble"];
        self.recordImageView.highlightedImage = [UIImage imageNamed:@"AddEntryMedicineBubble"];
        self.recordTitleLabel.text = [NSString stringWithFormat:@"%@ (%@)", [medicine name], [[IMEventController sharedInstance] medicineTypeHR:[[medicine type] integerValue]]];
        
    } else if([object isKindOfClass:[IMActivity class]]) {
        
        IMActivity *activity = (IMActivity *)object;
        
        self.recordTitleLabel.text = [activity name];
        self.recordImageView.image = [UIImage imageNamed:@"AddEntryActivityBubble"];
        self.recordImageView.highlightedImage = [UIImage imageNamed:@"AddEntryActivityBubble"];
        self.recordValueLabel.text = [IMHelper formatMinutes:[[activity minutes] doubleValue]];
        self.recordValueLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        
    } else if([object isKindOfClass:[IMNote class]]) {
        
        IMNote *note = (IMNote *)object;
        self.recordImageView.image = [UIImage imageNamed:@"AddEntryNoteBubble"];
        self.recordImageView.highlightedImage = [UIImage imageNamed:@"AddEntryNoteBubble"];
        self.recordTitleLabel.text = [note name];
        
    }
    
    NSDateFormatter *formatter = [IMHelper hhmmTimeFormatter];
    NSString *formattedTimestamp = [formatter stringFromDate:date];
    
    self.recordTimeLabel.text = formattedTimestamp;

    CGFloat topAlpha = 0.5f;
    CGFloat bottomAlpha = 0.5f;

    if (top == NO) {
        topAlpha = 0.0f;
    }
    if (bottom == NO) {
        bottomAlpha = 0.0f;
    }
    
    self.topLineView.alpha = topAlpha;
    self.bottomLineView.alpha = bottomAlpha;
}

@end
