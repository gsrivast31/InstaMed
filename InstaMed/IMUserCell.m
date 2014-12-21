//
//  IMUserCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMUserCell.h"
#import "IMUser.h"

@interface IMUserCell()
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *username;

@end

@implementation IMUserCell

- (void) configureCellForEntry:(IMUser *)entry {
    
    if (entry.relationship) {
        self.username.text = entry.relationship;
    } else {
        self.username.text = entry.name;
    }
    
    if (entry.profilePhoto) {
        self.profilePhoto.image = [UIImage imageWithData:entry.profilePhoto];
    } else {
        if (entry.gender == IMUserFemale) {
            self.profilePhoto.image = [UIImage imageNamed:@"icn_male"];
        } else {
            self.profilePhoto.image = [UIImage imageNamed:@"icn_male"];
        }
    }
    
    self.profilePhoto.layer.cornerRadius = CGRectGetWidth(self.profilePhoto.frame) / 2.0f;
}

@end
