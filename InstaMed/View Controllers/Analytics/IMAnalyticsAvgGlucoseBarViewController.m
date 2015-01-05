//
//  IMAnalyticsAvgGlucoseBarViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsAvgGlucoseBarViewController.h"

// Views
#import "JBBarChartView.h"
#import "IMAnalyticsChartHeaderView.h"
#import "IMAnalyticsBarChartFooterView.h"
#import "IMAnalyticsChartInformationView.h"

#import "IMAnalyticsConstants.h"

#import "OrderedDictionary.h"
#import "IMEvent.h"
#import "IMBGReading.h"

// Numerics
// Numerics
static CGFloat const kIMBarChartViewControllerChartHeight = 250.0f;
static CGFloat const kIMBarChartViewControllerChartPadding = 10.0f;
static CGFloat const kIMBarChartViewControllerChartHeaderHeight = 80.0f;
static CGFloat const kIMBarChartViewControllerChartHeaderPadding = 20.0f;
static CGFloat const kIMBarChartViewControllerChartFooterHeight = 25.0f;
static CGFloat const kIMBarChartViewControllerChartFooterPadding = 5.0f;
static CGFloat const kIMBarChartViewControllerBarPadding = 1.0f;

// Strings
static NSString * const kIMBarChartViewControllerNavButtonViewKey = @"view";

@interface IMAnalyticsAvgGlucoseBarViewController () <JBBarChartViewDelegate, JBBarChartViewDataSource>

@property (nonatomic, strong) JBBarChartView *barChartView;
@property (nonatomic, strong) IMAnalyticsChartInformationView *informationView;

@end

@implementation IMAnalyticsAvgGlucoseBarViewController

#pragma mark - Chart logic

- (NSDictionary *)parseData:(NSArray *)theData {
    NSDate *minDate = [NSDate distantFuture];
    NSDate *maxDate = [NSDate distantPast];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    OrderedDictionary *dictionary = [OrderedDictionary dictionary];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    theData = [theData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for(IMEvent *event in theData) {
        if([event isKindOfClass:[IMBGReading class]]) {
            NSDate *timestamp = [event.timestamp dateAtStartOfDay];
            if([timestamp isEarlierThanDate:minDate]) minDate = timestamp;
            if([timestamp isLaterThanDate:maxDate]) maxDate = timestamp;
            
            NSMutableArray *events = nil;
            NSString *key = [dateFormatter stringFromDate:timestamp];
            if(!dictionary[key]) {
                events = [NSMutableArray array];
            } else {
                events = [NSMutableArray arrayWithArray:[dictionary objectForKey:key]];
            }
            [events addObject:event];
            
            dictionary[key] = events;
        }
    }
    
    NSMutableArray *formattedData = [NSMutableArray array];
    for(NSString *date in dictionary) {
        if([dictionary[date] count] >= 1) {
            double readingTotal = 0.0f;
            for (IMBGReading *reading in dictionary[date]) {
                readingTotal = readingTotal + [reading.value doubleValue];
            }
            double readingAvg = readingTotal/(double)[dictionary[date] count];
            [formattedData addObject:@{@"date":date, @"avgGlucose":[NSNumber numberWithDouble:readingAvg]}];
        }
    }
    
    // Stop a crash from occuring if our minDate equals our maxDate
    if([minDate isEqualToDate:maxDate]) {
        maxDate = [maxDate dateByAddingHours:1];
    }
    
    return @{@"minDate": minDate, @"maxDate": maxDate, @"data": formattedData};
}

- (BOOL)hasEnoughDataToShowChart {
    if([[chartData objectForKey:@"data"] count] > 1) {
        return YES;
    }
    return NO;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kIMColorBarChartControllerBackground;
    self.title = @"Average Blood Glucose";
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat chartY = (screenRect.size.height - navigationBarHeight - statusBarHeight - kIMBarChartViewControllerChartHeight)/2.0f;
    
    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.frame = CGRectMake(kIMBarChartViewControllerChartPadding, chartY, self.view.bounds.size.width - (kIMBarChartViewControllerChartPadding * 2), kIMBarChartViewControllerChartHeight);
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    self.barChartView.headerPadding = kIMBarChartViewControllerChartHeaderPadding;
    self.barChartView.minimumValue = 0.0f;
    self.barChartView.inverted = NO;
    self.barChartView.backgroundColor = kIMColorBarChartBackground;
    
    CGFloat y = ceil(self.view.bounds.size.height * 0.5) - ceil(kIMBarChartViewControllerChartHeaderHeight * 0.5);

    IMAnalyticsChartHeaderView *headerView = [[IMAnalyticsChartHeaderView alloc] initWithFrame:CGRectMake(kIMBarChartViewControllerChartPadding, y, self.view.bounds.size.width - (kIMBarChartViewControllerChartPadding * 2), kIMBarChartViewControllerChartHeaderHeight)];
    headerView.titleLabel.text = [self dateString];
    headerView.subtitleLabel.text = @"";
    headerView.separatorColor = kIMColorBarChartHeaderSeparatorColor;
    self.barChartView.headerView = headerView;
    
    IMAnalyticsBarChartFooterView *footerView = [[IMAnalyticsBarChartFooterView alloc] initWithFrame:CGRectMake(kIMBarChartViewControllerChartPadding, y, self.view.bounds.size.width - (kIMBarChartViewControllerChartPadding * 2), kIMBarChartViewControllerChartFooterHeight)];
    footerView.padding = kIMBarChartViewControllerChartFooterPadding;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    footerView.leftLabel.text = [dateFormatter stringFromDate:[chartData objectForKey:@"minDate"]];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [dateFormatter stringFromDate:[chartData objectForKey:@"maxDate"]];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    self.barChartView.footerView = footerView;
    
    self.informationView = [[IMAnalyticsChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.barChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.barChartView.frame))];
    [self.view addSubview:self.informationView];
    
    [self.view addSubview:self.barChartView];
    [self.barChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.barChartView setState:JBChartViewStateExpanded];
}

#pragma mark - IMAnalyticsChartViewDataSource

- (BOOL)shouldExtendSelectionViewIntoHeaderPaddingForChartView:(JBChartView *)chartView {
    return YES;
}

- (BOOL)shouldExtendSelectionViewIntoFooterPaddingForChartView:(JBChartView *)chartView {
    return NO;
}

#pragma mark - IMAnalyticsBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBChartView *)barChartView {
    return [[chartData objectForKey:@"data"] count];
}

- (void)barChartView:(JBChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint {
    NSDictionary *info = (NSDictionary *)[[chartData objectForKey:@"data"] objectAtIndex:index];
    NSString *date = [info objectForKey:@"date"];
    NSNumber *valueNumber = [info objectForKey:@"avgGlucose"];
    
    NSString* unit = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey] == BGTrackingUnitMG ? @"mg/dL" : @"mmoI/L";
    [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber doubleValue]] unitText:unit];
    [self.informationView setTitleText:@"Avg Glucose"];
    [self.informationView setHidden:NO animated:YES];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:date];
}

- (void)didDeselectBarChartView:(JBChartView *)barChartView {
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index {
    NSDictionary *info = (NSDictionary *)[[chartData objectForKey:@"data"] objectAtIndex:index];
    return [[info objectForKey:@"avgGlucose"] floatValue];
}

- (UIColor *)barChartView:(JBChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index {
    return (index % 2 == 0) ? kIMColorBarChartBarBlue : kIMColorBarChartBarGreen;
}

- (UIColor *)barSelectionColorForBarChartView:(JBChartView *)barChartView {
    return [UIColor whiteColor];
}

- (CGFloat)barPaddingForBarChartView:(JBChartView *)barChartView {
    return kIMBarChartViewControllerBarPadding;
}

#pragma mark - Overrides

- (JBChartView *)chartView {
    return self.barChartView;
}

@end
