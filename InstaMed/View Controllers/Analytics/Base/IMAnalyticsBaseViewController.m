//
//  IMAnalyticsBaseViewController.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsBaseViewController.h"
#import "IMAnalyticsConstants.h"

@interface IMAnalyticsBaseViewController ()

@end

@implementation IMAnalyticsBaseViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kJBImageIconJawboneLogo]];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Getters

- (UIBarButtonItem *)chartToggleButtonWithTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kJBImageIconArrow] style:UIBarButtonItemStylePlain target:target action:action];
    return button;
}

@end
