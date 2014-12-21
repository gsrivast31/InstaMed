//
//  IMEventInputLabelViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 23/07/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMEventInputLabelViewCell.h"

@implementation IMEventInputLabelViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, self.contentView.bounds.size.width-20.0f, self.contentView.frame.size.height)];
        label.font = [IMFont standardMediumFontWithSize:16.0f];
        label.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        
        self.control = label;
    }
    return self;
}

@end
