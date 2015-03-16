//
//  IMReportTableViewCell.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 16/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportTableViewCell.h"

@interface IMReportTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *icon;

@end

@implementation IMReportTableViewCell

- (void) configureCellForEntry:(NSString *)name forIndex:(NSInteger)index{
    [self.name setText:name];
    NSString* startChar = [name substringToIndex:1];
    [self.icon setTitle:startChar forState:UIControlStateNormal];
    [self.icon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    switch (index) {
        case 0:
            [self.icon setBackgroundColor:[UIColor blueColor]];
            break;
        case 1:
            [self.icon setBackgroundColor:[UIColor magentaColor]];
            break;
        case 2:
            [self.icon setBackgroundColor:[UIColor grayColor]];
            break;
        case 3:
            [self.icon setBackgroundColor:[UIColor cyanColor]];
            break;
        case 4:
            [self.icon setBackgroundColor:[UIColor orangeColor]];
            break;
        case 5:
            [self.icon setBackgroundColor:[UIColor purpleColor]];
            break;
        case 6:
            [self.icon setBackgroundColor:[UIColor greenColor]];
            break;
    }
    
    self.icon.alpha = 0.5f;
    //self.icon.layer.cornerRadius = CGRectGetWidth(self.icon.frame) / 2.0f;
}

@end
