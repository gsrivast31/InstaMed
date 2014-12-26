//
//  IMEntryListTableViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 19/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEntryListTableViewCell.h"

@interface IMEntryListTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *entryNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *entryImageView;

@end
@implementation IMEntryListTableViewCell

- (void) configureCellForEventType:(enum IMEventType)eventType eventName:(NSString*)name{
    UIImage* image = nil;
    if (eventType == IMMedicineType) {
        image = [UIImage imageNamed:@"AddEntryMedicineBubble"];
    } else if (eventType == IMBGReadingType) {
        image = [UIImage imageNamed:@"AddEntryBloodBubble"];
    } else if (eventType == IMBPReadingType) {
        image = [UIImage imageNamed:@"AddEntryBloodBubble"];
    } else if (eventType == IMCholesterolType) {
        image = [UIImage imageNamed:@"AddEntryBloodBubble"];
    } else if (eventType == IMWeightType) {
        image = [UIImage imageNamed:@"AddEntryBloodBubble"];
    } else if (eventType == IMFoodType) {
        image = [UIImage imageNamed:@"AddEntryMealBubble"];
    } else if (eventType == IMActivityType) {
        image = [UIImage imageNamed:@"AddEntryActivityBubble"];
    } else if (eventType == IMNoteType) {
        image = [UIImage imageNamed:@"AddEntryNoteBubble"];
    }
    self.entryNameLabel.text = name;
    self.entryImageView.image = image;
    self.entryImageView.layer.cornerRadius = CGRectGetWidth(self.entryImageView.frame) / 2.0f;
}

@end
