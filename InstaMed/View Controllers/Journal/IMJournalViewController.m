//
//  IMJournalViewController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 30/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "NSDate+Extension.h"

#import "IMJournalViewController.h"
#import "IMJournalMonthViewCell.h"

#import "IMEntryListTableViewController.h"
#import "IMEventController.h"

#import "IMEvent.h"
#import "IMBGReading.h"
#import "IMShortcutButton.h"

#import "IMDayRecordTableViewController.h"
#import "CAGradientLayer+IMGradients.h"

@interface IMJournalViewController ()
{
    NSDictionary *readings;
    NSDateFormatter *dateFormatter;
    
    id settingsChangeNotifier;
    id userChangeNotifier;
    id entryNotifier;
    
    IMShortcutButton *todayButton, *sevenDayButton, *fourteenDayButton;
    
    double todaysMean, sevenDaysMean, fourteenDaysMean;
    double todaysHighest, sevenDaysHighest, fourteenDaysHighest;
    NSInteger todaysCount, sevenDaysCount, fourteenDaysCount;
}
@end

@implementation IMJournalViewController

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        self.title = NSLocalizedString(@APP_NAME, @"The title for the applications index screen - which is a physical journal");
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM yyyy"];
        
        // Notifications
        settingsChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kSettingsChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf reloadViewData:note];
        }];
        
        userChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kCurrentProfileChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf reloadViewData:note];
        }];

        entryNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kEntryAddUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf reloadViewData:note];
        }];

        // Menu items
        UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconAdd"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent:)];
        [self.navigationItem setRightBarButtonItem:addBarButtonItem animated:NO];
    
        UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconListMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu:)];
        [self.navigationItem setLeftBarButtonItem:menuBarButtonItem animated:NO];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:settingsChangeNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:userChangeNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:entryNotifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[IMJournalMonthViewCell class] forCellReuseIdentifier:@"IMJournalMonthViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"IMJournalSpacerViewCell"];
    
    // Setup our table header view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 120.0f)];
    //headerView.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    headerView.backgroundColor = [UIColor clearColor];

    CAGradientLayer *backgroundLayer = [CAGradientLayer sideGradientLayer];
    backgroundLayer.frame = headerView.frame;
    [headerView.layer insertSublayer:backgroundLayer atIndex:0];

    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    todayButton = [[IMShortcutButton alloc] initWithFrame:CGRectZero];
    [todayButton setTitle:[NSLocalizedString(@"Today", nil) uppercaseString] forState:UIControlStateNormal];
    [todayButton setImage:[UIImage imageNamed:@"today"] forState:UIControlStateNormal];
    [todayButton setImage:[UIImage imageNamed:@"today"] forState:UIControlStateHighlighted];
    [todayButton setImage:[UIImage imageNamed:@"today"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [todayButton setExclusiveTouch:YES];
    [todayButton setTag:0];
    [todayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:todayButton];
    
    sevenDayButton = [[IMShortcutButton alloc] initWithFrame:CGRectZero];
    [sevenDayButton setTitle:[NSLocalizedString(@"Past 7 Days", nil) uppercaseString] forState:UIControlStateNormal];
    [sevenDayButton setImage:[UIImage imageNamed:@"last7days"] forState:UIControlStateNormal];
    [sevenDayButton setImage:[UIImage imageNamed:@"last7days"] forState:UIControlStateHighlighted];
    [sevenDayButton setImage:[UIImage imageNamed:@"last7days"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [sevenDayButton setExclusiveTouch:YES];
    [sevenDayButton setTag:7];
    [sevenDayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:sevenDayButton];
    
    fourteenDayButton = [[IMShortcutButton alloc] initWithFrame:CGRectZero];
    [fourteenDayButton setTitle:[NSLocalizedString(@"Past 14 days", nil) uppercaseString] forState:UIControlStateNormal];
    [fourteenDayButton setImage:[UIImage imageNamed:@"last14days"] forState:UIControlStateNormal];
    [fourteenDayButton setImage:[UIImage imageNamed:@"last14days"] forState:UIControlStateHighlighted];
    [fourteenDayButton setImage:[UIImage imageNamed:@"last14days"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [fourteenDayButton setExclusiveTouch:YES];
    [fourteenDayButton setTag:14];
    [fourteenDayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:fourteenDayButton];
    
    self.tableView.tableHeaderView = headerView;

    [self reloadViewData:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat buttonWidth = floorf(self.view.frame.size.width/3.0f);
    todayButton.frame = CGRectMake(0.0f, 0.0f, buttonWidth, 119.0f);
    sevenDayButton.frame = CGRectMake(buttonWidth, 0.0f, buttonWidth, 119.0f);
    fourteenDayButton.frame = CGRectMake(buttonWidth*2.0f, 0.0f, buttonWidth, 119.0f);
}

#pragma mark - Logic
- (OrderedDictionary *)fetchReadingData {
    OrderedDictionary *data = [OrderedDictionary dictionary];
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    NSArray *objects = @[];
    NSError *error = nil;
    if(moc) {
        // Save any changes the MOC has waiting in the wings
        if([moc hasChanges]) {
            NSError *error = nil;
            [moc save:&error];
        }
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMEvent" inManagedObjectContext:moc];
        [request setEntity:entity];
        [request setSortDescriptors:@[sortDescriptor]];
        [request setReturnsObjectsAsFaults:NO];
        
        NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userGuid = %@", currentUserGuid];
        [request setPredicate:predicate];

        objects = [moc executeFetchRequest:request error:&error];
    }
    
    // Force objects to be empty if we run into errors
    if(error || !objects) objects = @[];
    
    NSString *title = nil;
    NSDate *currentDate = [NSDate date];
    NSInteger month = 6;
    if([objects count]) {
        month = [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth
                                                 fromDate:(NSDate *)[[objects lastObject] valueForKey:@"timestamp"]
                                                   toDate:[NSDate date]
                                                  options:0] month];
        month++;
    }
    
    if(month < 6) month = 6;
    
    for(NSInteger i = 0; i <= month; i++) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:1];
        [comps setMonth:[currentDate month]-i];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setYear:[currentDate year]];
        
        NSDate *fromDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
        NSDate *toDate = [fromDate dateAtEndOfMonth];
        
        if(fromDate && toDate) {
            NSDictionary *stats = [[IMEventController sharedInstance] statisticsForEvents:objects fromDate:fromDate toDate:toDate];
            
            title = [dateFormatter stringFromDate:fromDate];
            [data setObject:stats forKey:title];
        }
    }
    
    return data;
}

- (void)refreshView {
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
    [self.tableView setNeedsDisplay];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)reloadViewData:(NSNotification *)note {
    [super reloadViewData:note];

    readings = [self fetchReadingData];
    [self refreshView];
}

#pragma mark - UI
- (void)addEvent:(id)sender{
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    IMEntryListTableViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"entryListTableViewController"];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)showSideMenu:(id)sender {
    IMAppDelegate *delegate = (IMAppDelegate*)[[UIApplication sharedApplication] delegate];
    [(REFrostedViewController *)delegate.viewController presentMenuViewController];
}

- (void)showRelativeTimeline:(IMShortcutButton *)sender {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    IMDayRecordTableViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"dayRecordTableViewController"];
    [vc setRelativeDays:sender.tag];
    
    vc.title = [sender titleForState:UIControlStateNormal];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate functions
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row%2 == 0) {
        [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
        
        indexPath = [NSIndexPath indexPathForRow:indexPath.row/2 inSection:indexPath.section];
        NSString *key = [[readings allKeys] objectAtIndex:indexPath.row];
        if(key) {
            NSDictionary *data = [readings objectForKey:key];
            
            //IMTimelineViewController *vc = [[IMTimelineViewController alloc] initWithDateFrom:[data valueForKey:@"min_date"] to:[data valueForKey:@"max_date"]];
            UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            IMDayRecordTableViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"dayRecordTableViewController"];
            [vc setDateFrom:[data valueForKey:@"min_date"] to:[data valueForKey:@"max_date"]];
            
            vc.title = key;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row%2 == 0) {
        CGFloat height = 158.0f;
        if ([IMHelper includeWeightReadings]) {
            height += 56.0f;
        }
        if ([IMHelper includeBPReadings]) {
            height += 56.0f;
        }
        if ([IMHelper includeCholesterolReadings]) {
            height += 56.0f;
        }
        if ([IMHelper includeGlucoseReadings]) {
            height += 56.0f;
        }
        return height;
    }
    return 20.0f;
}

#pragma mark - UITableViewDataSource functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if(readings) {
        return [[readings allKeys] count]*2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
    NSNumberFormatter *glucoseFormatter = [IMHelper glucoseNumberFormatter];
    NSNumberFormatter *cholesterolFormatter = [IMHelper cholesterolNumberFormatter];
    
    if(indexPath.row%2 == 0) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row/2 inSection:indexPath.section];
        
        IMJournalMonthViewCell *cell = (IMJournalMonthViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMJournalMonthViewCell" forIndexPath:indexPath];
  
        NSString *key = [[readings allKeys] objectAtIndex:indexPath.row];
        NSDictionary *stats = [readings objectForKey:key];
       
        NSInteger totalGrams = [[stats valueForKey:kTotalGramsKey] integerValue];
        NSInteger totalBGReadings = [[stats valueForKey:kBGReadingsTotalKey] integerValue];
        NSInteger totalChReadings = [[stats valueForKey:kChReadingsTotalKey] integerValue];
        NSInteger totalMinutes = [[stats objectForKey:kTotalMinutesKey] integerValue];
        
        double bgReadingsAvg = [[stats valueForKey:kBGReadingsAverageKey] doubleValue];
        //double bgReadingsDeviation = [[stats valueForKey:kBGReadingsDeviationKey] doubleValue];
        double lowGlucose = [[stats valueForKey:kBGReadingLowestKey] doubleValue];
        double highGlucose = [[stats valueForKey:kBGReadingHighestKey] doubleValue];
        
        double chReadingsAvg = [[stats valueForKey:kChReadingsAverageKey] doubleValue];
        //double chReadingsDeviation = [[stats valueForKey:kChReadingsDeviationKey] doubleValue];
        double lowCholesterol = [[stats valueForKey:kChReadingLowestKey] doubleValue];
        double highCholesterol = [[stats valueForKey:kChReadingHighestKey] doubleValue];
        
        uint lowBP = [[stats valueForKey:kBPReadingLowestKey] unsignedIntValue];
        uint highBP = [[stats valueForKey:kBPReadingHighestKey] unsignedIntValue];
        
        double lowWeight = [[stats valueForKey:kWtReadingLowestKey] doubleValue];
        double highWeight = [[stats valueForKey:kWtReadingHighestKey] doubleValue];
        
        if ([IMHelper includeGlucoseReadings]) {
            if(totalBGReadings) {
                [cell setAverageGlucoseValue:[NSNumber numberWithDouble:bgReadingsAvg] withFormatter:glucoseFormatter];
                //[cell setBGDeviationValue:[NSNumber numberWithDouble:bgReadingsDeviation] withFormatter:glucoseFormatter];
            } else {
                [cell setAverageGlucoseValue:[NSNumber numberWithDouble:0.0] withFormatter:glucoseFormatter];
                //[cell setBGDeviationValue:[NSNumber numberWithDouble:0.0] withFormatter:glucoseFormatter];
            }
            [cell setLowGlucoseValue:[NSNumber numberWithDouble:lowGlucose] withFormatter:glucoseFormatter];
            [cell setHighGlucoseValue:[NSNumber numberWithDouble:highGlucose] withFormatter:glucoseFormatter];
        }

        if ([IMHelper includeCholesterolReadings]) {
            if(totalChReadings) {
                [cell setAverageCholesterolValue:[NSNumber numberWithDouble:chReadingsAvg] withFormatter:cholesterolFormatter];
                //[cell setChDeviationValue:[NSNumber numberWithDouble:chReadingsDeviation] withFormatter:cholesterolFormatter];
            } else {
                [cell setAverageCholesterolValue:[NSNumber numberWithDouble:0.0] withFormatter:cholesterolFormatter];
                //[cell setChDeviationValue:[NSNumber numberWithDouble:0.0] withFormatter:cholesterolFormatter];
            }
            [cell setLowCholesterolValue:[NSNumber numberWithDouble:lowCholesterol] withFormatter:cholesterolFormatter];
            [cell setHighCholesterolValue:[NSNumber numberWithDouble:highCholesterol] withFormatter:cholesterolFormatter];
        }

        if ([IMHelper includeBPReadings]) {
            [cell setLowBPValue:[NSNumber numberWithUnsignedInt:lowBP] withFormatter:valueFormatter];
            [cell setHighBPValue:[NSNumber numberWithUnsignedInt:highBP] withFormatter:valueFormatter];
            [cell setBPState:(lowBP || highBP)];
        }
        
        if ([IMHelper includeWeightReadings]) {
            [cell setLowWeightValue:[NSNumber numberWithDouble:lowWeight] withFormatter:valueFormatter];
            [cell setHighWeightValue:[NSNumber numberWithDouble:highWeight] withFormatter:valueFormatter];
            [cell setWeightState:(lowWeight > 0 || highWeight > 0)];
        }
        
        [cell setMealValue:[NSNumber numberWithDouble:totalGrams] withFormatter:valueFormatter];
        [cell setActivityValue:totalMinutes];
        cell.monthLabel.text = key;
        
        return cell;
    }
    else {
        UITableViewCell *cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMJournalSpacerViewCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Helpers
- (NSString *)keyForIndexPath:(NSIndexPath *)aIndexPath {
    NSInteger i = 0;
    for(NSString *key in readings) {
        if(i == aIndexPath.row) return key;
        i++;
    }
    
    return nil;
}

@end
