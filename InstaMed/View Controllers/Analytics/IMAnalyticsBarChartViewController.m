//
//  IMAnalyticsBarChartViewController.m
//  IMAnalyticsChartViewDemo
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsBarChartViewController.h"

// Views
#import "JBBarChartView.h"
#import "IMAnalyticsChartHeaderView.h"
#import "IMAnalyticsBarChartFooterView.h"
#import "IMAnalyticsChartInformationView.h"

#import "IMAnalyticsConstants.h"

// Numerics
CGFloat const kJBBarChartViewControllerChartHeight = 250.0f;
CGFloat const kJBBarChartViewControllerChartPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartHeaderHeight = 80.0f;
CGFloat const kJBBarChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBBarChartViewControllerChartFooterHeight = 25.0f;
CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
CGFloat const kJBBarChartViewControllerBarPadding = 1.0f;
NSInteger const kJBBarChartViewControllerNumBars = 12;
NSInteger const kJBBarChartViewControllerMaxBarHeight = 10;
NSInteger const kJBBarChartViewControllerMinBarHeight = 5;

// Strings
NSString * const kJBBarChartViewControllerNavButtonViewKey = @"view";

@interface IMAnalyticsBarChartViewController () <JBBarChartViewDelegate, JBBarChartViewDataSource>

@property (nonatomic, strong) JBBarChartView *barChartView;
@property (nonatomic, strong) IMAnalyticsChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *monthlySymbols;

// Buttons
- (void)chartToggleButtonPressed:(id)sender;

// Data
- (void)initFakeData;

@end

@implementation IMAnalyticsBarChartViewController

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

#pragma mark - Date

- (void)initFakeData
{
    NSMutableArray *mutableChartData = [NSMutableArray array];
    for (int i=0; i<kJBBarChartViewControllerNumBars; i++)
    {
        NSInteger delta = (kJBBarChartViewControllerNumBars - abs((kJBBarChartViewControllerNumBars - i) - i)) + 2;
        [mutableChartData addObject:[NSNumber numberWithFloat:MAX((delta * kJBBarChartViewControllerMinBarHeight), arc4random() % (delta * kJBBarChartViewControllerMaxBarHeight))]];

    }
    _chartData = [NSArray arrayWithArray:mutableChartData];
    _monthlySymbols = [[[NSDateFormatter alloc] init] shortMonthSymbols];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = kJBColorBarChartControllerBackground;
    self.navigationItem.rightBarButtonItem = [self chartToggleButtonWithTarget:self action:@selector(chartToggleButtonPressed:)];

    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.frame = CGRectMake(kJBBarChartViewControllerChartPadding, kJBBarChartViewControllerChartPadding, self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartHeight);
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    self.barChartView.headerPadding = kJBBarChartViewControllerChartHeaderPadding;
    self.barChartView.minimumValue = 0.0f;
    self.barChartView.inverted = NO;
    self.barChartView.backgroundColor = kJBColorBarChartBackground;
    
    IMAnalyticsChartHeaderView *headerView = [[IMAnalyticsChartHeaderView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartHeaderHeight)];
    headerView.titleLabel.text = [kJBStringLabelAverageMonthlyTemperature uppercaseString];
    headerView.subtitleLabel.text = kJBStringLabel2012;
    headerView.separatorColor = kJBColorBarChartHeaderSeparatorColor;
    self.barChartView.headerView = headerView;
    
    IMAnalyticsBarChartFooterView *footerView = [[IMAnalyticsBarChartFooterView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartFooterHeight)];
    footerView.padding = kJBBarChartViewControllerChartFooterPadding;
    footerView.leftLabel.text = [[self.monthlySymbols firstObject] uppercaseString];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [[self.monthlySymbols lastObject] uppercaseString];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    self.barChartView.footerView = footerView;
    
    self.informationView = [[IMAnalyticsChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.barChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.barChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    [self.view addSubview:self.informationView];

    [self.view addSubview:self.barChartView];
    [self.barChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.barChartView setState:JBChartViewStateExpanded];
}

#pragma mark - IMAnalyticsChartViewDataSource

- (BOOL)shouldExtendSelectionViewIntoHeaderPaddingForChartView:(JBChartView *)chartView
{
    return YES;
}

- (BOOL)shouldExtendSelectionViewIntoFooterPaddingForChartView:(JBChartView *)chartView
{
    return NO;
}

#pragma mark - IMAnalyticsBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBChartView *)barChartView
{
    return kJBBarChartViewControllerNumBars;
}

- (void)barChartView:(JBChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [self.chartData objectAtIndex:index];
    [self.informationView setValueText:[NSString stringWithFormat:kJBStringLabelDegreesFahrenheit, [valueNumber intValue], kJBStringLabelDegreeSymbol] unitText:nil];
    [self.informationView setTitleText:kJBStringLabelWorldwideAverage];
    [self.informationView setHidden:NO animated:YES];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:[[self.monthlySymbols objectAtIndex:index] uppercaseString]];
}

- (void)didDeselectBarChartView:(JBChartView *)barChartView
{
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    return [[self.chartData objectAtIndex:index] floatValue];
}

- (UIColor *)barChartView:(JBChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return (index % 2 == 0) ? kJBColorBarChartBarBlue : kJBColorBarChartBarGreen;
}

- (UIColor *)barSelectionColorForBarChartView:(JBChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (CGFloat)barPaddingForBarChartView:(JBChartView *)barChartView
{
    return kJBBarChartViewControllerBarPadding;
}

#pragma mark - Buttons

- (void)chartToggleButtonPressed:(id)sender
{
    UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:kJBBarChartViewControllerNavButtonViewKey];
    buttonImageView.userInteractionEnabled = NO;
    
    CGAffineTransform transform = self.barChartView.state == JBChartViewStateExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
    buttonImageView.transform = transform;
    
    [self.barChartView setState:self.barChartView.state == JBChartViewStateExpanded ? JBChartViewStateCollapsed : JBChartViewStateExpanded animated:YES callback:^{
        buttonImageView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Overrides

- (JBChartView *)chartView
{
    return self.barChartView;
}

@end
