//
//  IMBadgeView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 26/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMBadgeView : UIView
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *badgeColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedBadgeColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, assign) CGFloat badgePadding;
@property (nonatomic, assign) CGFloat badgeCornerRadius;

@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, strong) NSString *value;

@end
