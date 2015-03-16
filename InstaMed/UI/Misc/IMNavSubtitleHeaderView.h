//
//  IMNavSubtitleHeaderView.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 08/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMNavSubtitleHeaderView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

// Logic
- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;
@end
