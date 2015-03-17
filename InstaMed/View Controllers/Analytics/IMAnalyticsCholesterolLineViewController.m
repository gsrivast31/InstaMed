//
//  IMAnalyticsCholesterolLineViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsCholesterolLineViewController.h"


// Views
#import "JBLineChartView.h"
#import "IMAnalyticsChartHeaderView.h"
#import "IMAnalyticsLineChartFooterView.h"
#import "IMAnalyticsChartInformationView.h"
#import "IMAnalyticsConstants.h"

#import "OrderedDictionary.h"
#import "IMEvent.h"
#import "IMCholesterolReading.h"

// Numerics
static CGFloat const kIMLineChartViewControllerChartHeight = 250.0f;
static CGFloat const kIMLineChartViewControllerChartPadding = 10.0f;
static CGFloat const kIMLineChartViewControllerChartHeaderHeight = 75.0f;
static CGFloat const kIMLineChartViewControllerChartHeaderPadding = 20.0f;
static CGFloat const kIMLineChartViewControllerChartFooterHeight = 20.0f;

// Strings
static NSString * const kJBLineChartViewControllerNavButtonViewKey = @"view";

@interface IMAnalyticsCholesterolLineViewController () <JBLineChartViewDelegate, JBLineChartViewDataSource>

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) IMAnalyticsChartInformationView *informationView;

@end

@implementation IMAnalyticsCholesterolLineViewController

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
        if([event isKindOfClass:[IMCholesterolReading class]]) {
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
            IMCholesterolReading *lowReading = nil;
            IMCholesterolReading *highReading = nil;
            for(IMCholesterolReading *reading in dictionary[date]) {
                if(!highReading || [reading.mmoValue doubleValue] > [highReading.mmoValue doubleValue]) highReading = reading;
                if(!lowReading || [reading.mmoValue doubleValue] < [lowReading.mmoValue doubleValue]) lowReading = reading;
            }
            [formattedData addObject: @{@"date": date, @"low": lowReading.value, @"high": highReading.value}];
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
    
    self.view.backgroundColor = kIMColorLineChartControllerBackground;
    self.title = @"Cholesterol Levels";
    
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
    return [[chartData objectForKey:@"data"] count] > 0 ? 4 : 0;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
    return [[chartData objectForKey:@"data"] count];
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex {
    if (lineIndex >= 2) {
        return NO;
    }
    return YES;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex {
    return YES;
}

#pragma mark - IMAnalyticsLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    if (lineIndex < 2) {
        NSDictionary *info = (NSDictionary *)[[chartData objectForKey:@"data"] objectAtIndex:horizontalIndex];
        
        if (lineIndex == 0) {
            return [[info objectForKey:@"low"] floatValue];
        } else if (lineIndex == 1) {
            return [[info objectForKey:@"high"] floatValue];
        }
    }
    else if (lineIndex == 2) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kMinHealthyChKey] floatValue];
    } else {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kMaxHealthyChKey] floatValue];
    }
    return 0.0f;
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint {
    NSNumber* valueNumber = nil;
    NSString* title = nil;
    if (lineIndex < 2) {
        NSDictionary *info = (NSDictionary *)[[chartData objectForKey:@"data"] objectAtIndex:horizontalIndex];
        [self.tooltipView setText:[info objectForKey:@"date"]];
        [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
        
        if (lineIndex == 0) {
            valueNumber = [info objectForKey:@"low"];
            title = @"Lowest Reading";
        } else if (lineIndex == 1) {
            valueNumber = [info objectForKey:@"high"];
            title = @"Highest Reading";
        }
    } else if (lineIndex == 2) {
        valueNumber = [NSNumber numberWithDouble:[[[NSUserDefaults standardUserDefaults] objectForKey:kMinHealthyChKey] doubleValue]];
        title = @"Minimum Healthy Reading";
    } else {
        valueNumber = [NSNumber numberWithDouble:[[[NSUserDefaults standardUserDefaults] objectForKey:kMaxHealthyChKey] doubleValue]];
        title = @"Maximum Healthy Reading";
    }
    
    if (valueNumber) {
        NSString* unit = [[NSUserDefaults standardUserDefaults] integerForKey:kChTrackingUnitKey] == ChTrackingUnitMG ? @"mg/dL" : @"mmoI/L";
        [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:unit];
        [self.informationView setTitleText:title];
        [self.informationView setHidden:NO animated:YES];
    }
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView {
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
    if (lineIndex == 0) {
        return [UIColor redColor];
    } else if (lineIndex == 1) {
        return [UIColor blueColor];
    } else if (lineIndex == 2) {
        return [UIColor lightGrayColor];
    } else {
        return [UIColor darkGrayColor];
    }
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    if (lineIndex == 0) {
        return [UIColor redColor];
    } else if (lineIndex == 1) {
        return [UIColor blueColor];
    } else if (lineIndex == 2) {
        return [UIColor lightGrayColor];
    } else {
        return [UIColor darkGrayColor];
    }
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex {
    if (lineIndex < 2) {
        return 2.0f;
    }
    return 1.0f;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    return 5.0f;
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
    return (lineIndex < 2) ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

#pragma mark - Overrides

- (JBChartView *)chartView {
    return self.lineChartView;
}


@end
