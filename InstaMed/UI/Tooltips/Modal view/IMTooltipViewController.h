//
//  IMModalViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 29/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMTooltipView;
@class IMTooltipViewController;
@protocol IMTooltipViewControllerDelegate <NSObject>

@optional
- (void)willDisplayModalView:(IMTooltipViewController *)aModalController;
- (void)didDismissModalView:(IMTooltipViewController *)aModalController;

@end

@class IMModalViewPane;
@interface IMTooltipViewController : IMBaseViewController
@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, assign) id<IMTooltipViewControllerDelegate> delegate;

// Setup
- (id)initWithParentVC:(UIViewController *)parentVC andDelegate:(id <IMTooltipViewControllerDelegate>)delegate;

// Logic
- (void)setContentView:(IMTooltipView *)view;
- (void)present;
- (void)dismiss;

@end

@interface IMModalViewPane : UIView
@end