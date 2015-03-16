//
//  IMTagTableViewCell.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 26/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMTagTableViewCell.h"

@implementation IMTagTableViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.badgeView = [[IMBadgeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 25.0f)];
        [self.contentView addSubview:self.badgeView];
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.badgeView.frame = CGRectMake(self.contentView.bounds.size.width - self.badgeView.bounds.size.width, ceilf(self.contentView.bounds.size.height/2.0f - self.badgeView.bounds.size.height/2.0f), self.badgeView.bounds.size.width, self.badgeView.bounds.size.height);
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self.badgeView setHighlighted:highlighted];
}
@end
