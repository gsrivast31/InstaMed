//
//  IMUserCell.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMUserCell.h"
#import "IMUser.h"

@interface IMUserCell()
{
    IMUser* user;
}

@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UISwitch *selectSwitch;

@end

@implementation IMUserCell

- (void) configureCellForEntry:(IMUser *)entry {
    
    user = entry;
    
    if (entry.relationship && ![entry.relationship isEqualToString:@""]) {
        self.username.text = entry.relationship;
    } else {
        self.username.text = entry.name;
    }
    
    if (entry.profilePhoto) {
        self.profilePhoto.image = [UIImage imageWithData:entry.profilePhoto];
    } else {
        if (entry.gender == IMUserFemale) {
            self.profilePhoto.image = [UIImage imageNamed:@"icn_female"];
        } else {
            self.profilePhoto.image = [UIImage imageNamed:@"icn_male"];
        }
    }
    
    self.profilePhoto.layer.masksToBounds = YES;
    self.profilePhoto.layer.cornerRadius = CGRectGetWidth(self.profilePhoto.frame) / 2.0f;
    
    NSString* currentProfile = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
    BOOL isSelected = [currentProfile isEqualToString:user.guid];
    [self.selectSwitch setOn:isSelected animated:YES];
    if (isSelected) {
        self.selectSwitch.userInteractionEnabled = NO;
    } else {
        self.selectSwitch.userInteractionEnabled = YES;
    }
}

- (IBAction)switchTapped:(id)sender {
    NSString* currentProfile = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];

    BOOL selected = self.selectSwitch.on;
    if ([user.guid isEqualToString:currentProfile]) {
        self.selectSwitch.userInteractionEnabled = NO;
    } else {
        self.selectSwitch.userInteractionEnabled = YES;
        [[NSUserDefaults standardUserDefaults] setValue:user.guid forKey:kCurrentProfileKey];
        [[NSUserDefaults standardUserDefaults] setValue:user.name forKey:kCurrentProfileName];
        
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingDiabetes forKey:kCurrentProfileTrackingDiabetesKey];
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingCholesterol forKey:kCurrentProfileTrackingCholesterolKey];
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingHyperTension forKey:kCurrentProfileTrackingBPKey];
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingWeight forKey:kCurrentProfileTrackingWeightKey];
        
        [self.selectSwitch setOn:!selected animated:YES];

        // Post a notification so that we can determine when linking occurs
        NSDictionary* info = @{@"name":user.name,@"image":[UIImage imageWithData:user.profilePhoto]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentProfileChangedNotification object:nil userInfo:info];

    }
}

@end
