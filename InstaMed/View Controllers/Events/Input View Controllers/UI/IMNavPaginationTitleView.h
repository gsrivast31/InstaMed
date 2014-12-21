//
//  IMNavPaginationTitleView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMNavPageControl.h"

@interface IMNavPaginationTitleView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) IMNavPageControl *pageControl;

// Logic
- (void)setTitle:(NSString *)title;
@end
