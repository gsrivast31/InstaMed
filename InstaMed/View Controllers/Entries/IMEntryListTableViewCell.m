//
//  IMEntryListTableViewCell.m
//  HealthMemoir
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
        image = [UIImage imageNamed:@"Pill_filled"];
    } else if (eventType == IMBGReadingType) {
        image = [UIImage imageNamed:@"Diabetes_filled"];
    } else if (eventType == IMBPReadingType) {
        image = [UIImage imageNamed:@"BP_filled"];
    } else if (eventType == IMCholesterolType) {
        image = [UIImage imageNamed:@"Cholesterol_filled"];
    } else if (eventType == IMWeightType) {
        image = [UIImage imageNamed:@"Weight_filled"];
    } else if (eventType == IMFoodType) {
        image = [UIImage imageNamed:@"Food_filled"];
    } else if (eventType == IMActivityType) {
        image = [UIImage imageNamed:@"Activity_filled"];
    } else if (eventType == IMNoteType) {
        image = [UIImage imageNamed:@"Note"];
    }
    self.entryNameLabel.text = name;
    self.entryImageView.image = image;
    self.entryImageView.layer.cornerRadius = CGRectGetWidth(self.entryImageView.frame) / 2.0f;
}

@end
