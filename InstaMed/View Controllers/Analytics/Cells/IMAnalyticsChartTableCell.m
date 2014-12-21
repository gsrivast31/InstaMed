//
//  IMAnalyticsChartTableCell.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsChartTableCell.h"
#import "IMAnalyticsConstants.h"

@implementation IMAnalyticsChartTableCell

#pragma mark - Alloc/Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

#pragma mark - Setters

- (void)setType:(IMAnalyticsChartTableCellType)type
{
    _type = type;
    UIImage *image = nil;
    switch (type) {
        case IMAnalyticsChartTableCellTypeBarChart:
            image = [UIImage imageNamed:kJBImageIconBarChart];
            break;
        case IMAnalyticsChartTableCellTypeLineChart:
            image = [UIImage imageNamed:kJBImageIconLineChart];
            break;
        case IMAnalyticsChartTableCellTypeAreaChart:
            image = [UIImage imageNamed:kJBImageIconAreaChart];
            break;
        default:
            break;
    }
    self.accessoryView = [[UIImageView alloc] initWithImage:image];
}

@end
