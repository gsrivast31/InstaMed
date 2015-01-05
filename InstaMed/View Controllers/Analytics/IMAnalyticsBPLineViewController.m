//
//  IMAnalyticsBPLineViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsBPLineViewController.h"
// Views
#import "JBLineChartView.h"
#import "IMAnalyticsChartHeaderView.h"
#import "IMAnalyticsLineChartFooterView.h"
#import "IMAnalyticsChartInformationView.h"
#import "IMAnalyticsConstants.h"

#import "OrderedDictionary.h"
#import "IMEvent.h"
#import "IMBPReading.h"

// Numerics
static CGFloat const kIMLineChartViewControllerChartHeight = 250.0f;
static CGFloat const kIMLineChartViewControllerChartPadding = 10.0f;
static CGFloat const kIMLineChartViewControllerChartHeaderHeight = 75.0f;
static CGFloat const kIMLineChartViewControllerChartHeaderPadding = 20.0f;
static CGFloat const kIMLineChartViewControllerChartFooterHeight = 20.0f;

// Strings
static NSString * const kJBLineChartViewControllerNavButtonViewKey = @"view";

@interface IMAnalyticsBPLineViewController () <JBLineChartViewDelegate, JBLineChartViewDataSource>

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) IMAnalyticsChartInformationView *informationView;

@end

@implementation IMAnalyticsBPLineViewController

#pragma mark - Chart logic

- (NSDictionary *)parseData:(NSArray *)theData {
    NSDate *minDate = [NSDate distantFuture];
    NSDate *maxDate = [NSDate distantPast];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSMutableArray *formattedData = [NSMutableArray array];
    OrderedDictionary *dictionary = [OrderedDictionary dictionary];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    theData = [theData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for(IMEvent *event in theData) {
        if([event.timestamp isEarlierThanDate:minDate]) minDate = event.timestamp;
        if([event.timestamp isLaterThanDate:maxDate]) maxDate = event.timestamp;
        
        NSMutableDictionary *data = nil;
        NSString *key = [dateFormatter stringFromDate:event.timestamp];
        if(!(data = [dictionary objectForKey:key])) {
            data = [NSMutableDictionary dictionaryWithDictionary:@{@"date": [event.timestamp dateAtStartOfDay], @"lowBP": [NSNumber numberWithUnsignedInt:0], @"highBP": [NSNumber numberWithUnsignedInt:0]}];
        }
        
        if([event isKindOfClass:[IMBPReading class]]) {
            IMBPReading *reading = (IMBPReading *)event;
            
            [data setObject:reading.lowValue forKey:@"lowBP"];
            [data setObject:reading.highValue forKey:@"highBP"];
        }
        
        [dictionary setObject:data forKey:key];
    }
    
    for(NSString *key in dictionary) {
        NSDictionary *day = [dictionary objectForKey:key];
        uint lowValue = [[day objectForKey:@"lowBP"] unsignedIntValue];
        uint highValue = [[day objectForKey:@"highBP"] unsignedIntValue];
        if (lowValue > 0 || highValue > 0) {
            [formattedData addObject:[dictionary objectForKey:key]];
        }
    }
    
    minDate = [minDate dateAtStartOfDay];
    maxDate = [maxDate dateAtStartOfDay];
    
    // Stop a crash from occuring if our minDate equals our maxDate
    if([minDate isEqualToDate:maxDate]) {
        maxDate = [maxDate dateByAddingDays:1];
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
    
    self.view.backgroundColor = kIMColorLineChartControllerBackground;
    self.title = @"Blood Pressure Levels";
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat chartY = (screenRect.size.height - navigationBarHeight - statusBarHeight - kIMLineChartViewControllerChartHeight)/2.0f;
    
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(kIMLineChartViewControllerChartPadding, chartY, self.view.bounds.size.width - (kIMLineChartViewControllerChartPadding * 2), kIMLineChartViewControllerChartHeight);
    self.lineChartView.delegate = self;
    self.lineChartView.dataSource = self;
    self.lineChartView.headerPadding = kIMLineChartViewControllerChartHeaderPadding;
    self.lineChartView.backgroundColor = kIMColorLineChartBackground;
    
    CGFloat y = ceil(self.view.bounds.size.height * 0.5) - ceil(kIMLineChartViewControllerChartHeaderHeight * 0.5);
    IMAnalyticsChartHeaderView *headerView = [[IMAnalyticsChartHeaderView alloc] initWithFrame:CGRectMake(kIMLineChartViewControllerChartPadding, y, self.view.bounds.size.width - (kIMLineChartViewControllerChartPadding * 2), kIMLineChartViewControllerChartHeaderHeight)];
    headerView.titleLabel.text = [self dateString];
    headerView.titleLabel.textColor = kIMColorLineChartHeader;
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.subtitleLabel.text = @"";
    headerView.subtitleLabel.textColor = kIMColorLineChartHeader;
    headerView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.separatorColor = kIMColorLineChartHeaderSeparatorColor;
    self.lineChartView.headerView = headerView;
    
    IMAnalyticsLineChartFooterView *footerView = [[IMAnalyticsLineChartFooterView alloc] initWithFrame:CGRectMake(kIMLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kIMLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kIMLineChartViewControllerChartPadding * 2), kIMLineChartViewControllerChartFooterHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    footerView.leftLabel.text = [dateFormatter stringFromDate:[chartData objectForKey:@"minDate"]];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [dateFormatter stringFromDate:[chartData objectForKey:@"maxDate"]];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    footerView.sectionCount = [[chartData objectForKey:@"data"] count];
    self.lineChartView.footerView = footerView;
    
    [self.view addSubview:self.lineChartView];
    
    self.informationView = [[IMAnalyticsChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.lineChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.lineChartView.frame))];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
    [self.informationView setTitleTextColor:kIMColorLineChartHeader];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:kIMColorLineChartHeaderSeparatorColor];
    [self.view addSubview:self.informationView];
    
    [self.lineChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.lineChartView setState:JBChartViewStateExpanded];
}

#pragma mark - JBChartViewDataSource

- (BOOL)shouldExtendSelectionViewIntoHeaderPaddingForChartView:(JBLineChartView *)chartView {
    return YES;
}

- (BOOL)shouldExtendSelectionViewIntoFooterPaddingForChartView:(JBLineChartView *)chartView {
    return NO;
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView {
    return 2;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
    return [[chartData objectForKey:@"data"] count];
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex {
    return YES;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex {
    return NO;
}

#pragma mark - IMAnalyticsLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    NSDictionary *info = (NSDictionary *)[[chartData objectForKey:@"data"] objectAtIndex:horizontalIndex];
    
    CGFloat value = 0.0f;
    if (lineIndex == 0) {
        value = [[info objectForKey:@"lowBP"] floatValue];
    } else if (lineIndex == 1) {
        value = [[info objectForKey:@"highBP"] floatValue];
    }
    return value;
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint {
    NSDictionary *info = (NSDictionary *)[[chartData objectForKey:@"data"] objectAtIndex:horizontalIndex];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString* date = [dateFormatter stringFromDate:[info objectForKey:@"date"]];
    [self.tooltipView setText:date];
    
    NSNumber* valueNumber = nil;
    NSString* title = nil;
    if (lineIndex == 0) {
        valueNumber = [info objectForKey:@"lowBP"];
        title = @"Low Reading";
    } else if (lineIndex == 1) {
        valueNumber = [info objectForKey:@"highBP"];
        title = @"High Reading";
    }
    
    if (valueNumber) {
        [self.informationView setValueText:[NSString stringWithFormat:@"%d", [valueNumber unsignedIntValue]] unitText:@"mm Hg"];
        [self.informationView setTitleText:title];
        [self.informationView setHidden:NO animated:YES];
    }
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView {
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
    if (lineIndex == 0) {
        return [UIColor redColor];
    } else {
        return [UIColor blueColor];
    }
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    if (lineIndex == 0) {
        return [UIColor redColor];
    } else {
        return [UIColor blueColor];
    }
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex {
    return 2.0f;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    return 15.0f;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex {
    return [UIColor whiteColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex {
    return kIMColorLineChartDefaultDashedSelectedLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    return kIMColorLineChartDefaultDashedSelectedLineColor;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex {
    return (lineIndex < 3) ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

#pragma mark - Overrides

- (JBChartView *)chartView {
    return self.lineChartView;
}

@end
