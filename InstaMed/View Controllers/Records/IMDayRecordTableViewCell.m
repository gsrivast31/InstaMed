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
#import "IMTagHighlightTextStorage.h"

#define kNotesFont [IMFont standardUltraLightItalicFontWithSize:15.0f]
#define kNotesBottomVerticalPadding 13.0f
#define kBottomVerticalPadding 12.0f
#define kHorizontalMargin 16.0f

#define kInlinePhotoHeight 150.0f
#define kInlinePhotoInset 5.0f

@interface IMDayRecordTableViewCell ()
{
    IMTagHighlightTextStorage *textStorage;
}

@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;
@property (weak, nonatomic) IBOutlet UILabel *recordTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;

@property (nonatomic, strong) NSDictionary *metadata;

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

- (void)configureCellForEntry:(NSManagedObject*)object hasTop:(BOOL)top hasBottom:(BOOL)bottom withDate:(NSDate*)date withAlpha:(CGFloat)alpha withMetadata:(NSDictionary*)metadata withImage:(UIImage*)image {
    
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
    
    [self setPhotoImage:image];
    [self setMetaData:metadata];
}

- (void)setMetaData:(NSDictionary *)data {
    self.metadata = data;
    
    if(self.metadata) {
        NSString *notes = [data valueForKey:@"notes"];
        if(notes) {
            textStorage = [[IMTagHighlightTextStorage alloc] init];
            [textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:notes]];
            
            self.noteTextView.attributedText = textStorage;
            self.noteTextView.backgroundColor = [UIColor clearColor];
            self.noteTextView.font = kNotesFont;
            self.noteTextView.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
            self.noteTextView.editable = NO;
            self.noteTextView.textContainer.lineFragmentPadding = 0;
            self.noteTextView.textContainerInset = UIEdgeInsetsZero;
            self.noteTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.noteTextView.userInteractionEnabled = NO;
            
            if (self.photoImageView.image == nil) {
                self.textViewBottomConstraint.constant = 10;
            } else {
                self.textViewBottomConstraint.constant = 190;//20 + kInlinePhotoHeight;
            }
            self.noteTextView.alpha = 1.0f;
        } else {
            self.noteTextView.alpha = 0.0f;
        }
    }
    else
        self.noteTextView.alpha = 0.0f;
    
}

- (void)setPhotoImage:(UIImage *)image {
    if(!image) {
        self.photoImageView.alpha = 0.0f;
        return;
    }
    
    if(!self.photoImageView) {
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.photoImageView.clipsToBounds = YES;
        self.photoImageView.layer.cornerRadius = 4;
    }
    self.photoImageView.image = image;
}

#pragma mark - Helpers
+ (CGFloat)additionalHeightWithMetaData:(NSDictionary *)data width:(CGFloat)width
{
    CGFloat height = 0.0f;
    
    NSString *notes = [data objectForKey:@"notes"];
    if(notes) {
        //CGRect notesFrame = [notes boundingRectWithSize:CGSizeMake(width-96.0f-kHorizontalMargin, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:kNotesFont} context:nil];
        
        height += 25; //notesFrame.size.height+kNotesBottomVerticalPadding - 8.0f;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kShowInlineImages]) {
        NSString *photoPath = [data valueForKey:@"photoPath"];
        if(photoPath) {
            height += kInlinePhotoHeight + kInlinePhotoInset;
        }
    }
    
    return height;
}

@end
