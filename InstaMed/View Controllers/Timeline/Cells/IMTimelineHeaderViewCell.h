//
//  IMTimelineHeaderViewCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 14/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMTimelineStatView.h"

@interface IMTimelineHeaderViewCell : UITableViewCell
@property (nonatomic, retain) UILabel *dateLabel;

@property (nonatomic, retain) IMTimelineStatView *glucoseStatView;
@property (nonatomic, retain) IMTimelineStatView *activityStatView;
@property (nonatomic, retain) IMTimelineStatView *mealStatView;

// Logic
- (void)setDate:(NSString *)text;

@end
