//
//  IMEventInputViewCell.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 20/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMEventInputViewCell : UITableViewCell
@property (nonatomic, retain) UIView *borderView;
@property (nonatomic, retain) UIView *control;
@property (nonatomic, retain) UILabel *label;

// Logic
- (void)setDrawsBorder:(BOOL)border;
- (void)resetCell;

@end
