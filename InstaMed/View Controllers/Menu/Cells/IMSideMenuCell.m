//
//  IMSideMenuCell.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 27/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSideMenuCell.h"

@interface IMSideMenuCell ()
@end

@implementation IMSideMenuCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        
        self.textLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.45f];
        self.textLabel.font = [IMFont standardMediumFontWithSize:16.0f];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.autoresizingMask = UIViewAutoresizingNone;
        
        self.detailTextLabel.font = [IMFont standardRegularFontWithSize:12.0f];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
        
        self.accessoryIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 28.0f, self.bounds.size.height)];
        self.accessoryIcon.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.accessoryIcon];
        
        UIEdgeInsets customSeparatorInset = self.separatorInset;
        customSeparatorInset.left = 0.0f;
        self.separatorInset = customSeparatorInset;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleHeight = 18.0f;
    CGFloat detailHeight = 16.0f;
    CGFloat height = titleHeight;
    if(self.detailTextLabel.text)
    {
        height += 3.0f + detailHeight;
    }
    CGFloat y = ceilf(self.contentView.bounds.size.height/2.0f - height/2.0f);
    
    self.textLabel.frame = CGRectMake(45.0f, y, 198.0f, titleHeight);
    self.detailTextLabel.frame = CGRectMake(45.0f, y + 3.0f + self.textLabel.frame.size.height, 198.0f, detailHeight);
    self.accessoryIcon.frame = CGRectMake(self.accessoryIcon.frame.origin.x, ceilf(self.frame.size.height/2 - self.accessoryIcon.frame.size.height/2), self.accessoryIcon.frame.size.width, self.accessoryIcon.frame.size.height);
}

@end