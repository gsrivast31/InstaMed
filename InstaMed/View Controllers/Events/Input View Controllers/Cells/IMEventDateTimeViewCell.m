//
//  IMEventDateTimeViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 23/07/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMEventDateTimeViewCell.h"

@implementation IMEventDateTimeViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        
        _datePicker = [[UIDatePicker alloc] init];
        [self.contentView addSubview:_datePicker];
    }
    return self;
}

@end
