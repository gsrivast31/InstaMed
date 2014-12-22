//
//  IMJournalTableViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMJournalTableViewController.h"

#import "IMEntryListTableViewController.h"
#import "IMDayRecordTableViewController.h"

#import "IMIntroductionTooltipView.h"
#import "IMJournalTableViewCell.h"
#import "IMShortcutButton.h"

#import "OrderedDictionary.h"
#import "IMEventController.h"
#import "IMCoreDataStack.h"

@interface IMJournalTableViewController () <UIActionSheetDelegate, IMTooltipViewControllerDelegate>
{
    NSDictionary *readings;
    NSDateFormatter *dateFormatter;
    
    id settingsChangeNotifier;
    
    IMShortcutButton *todayButton, *sevenDayButton, *fourteenDayButton;
    
    double todaysMean, sevenDaysMean, fourteenDaysMean;
    double todaysHighest, sevenDaysHighest, fourteenDaysHighest;
    NSInteger todaysCount, sevenDaysCount, fourteenDaysCount;
}
@end

@implementation IMJournalTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)awakeFromNib {
    __weak typeof(self) weakSelf = self;

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM yyyy"];
    
    // Notifications
    settingsChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kSettingsChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reloadViewData:note];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:settingsChangeNotifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Journal", @"The title for the applications index screen - which is a physical journal");
    
    // Menu items
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconAdd"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent:)];

    [self.navigationItem setRightBarButtonItem:addBarButtonItem animated:NO];
    
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconListMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu:)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem animated:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"IMJournalSpacerViewCell"];
    
    // Setup our table header view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 120.0f)];
    headerView.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    todayButton = [[IMShortcutButton alloc] initWithFrame:CGRectZero];
    [todayButton setTitle:[NSLocalizedString(@"Today", nil) uppercaseString] forState:UIControlStateNormal];
    [todayButton setImage:[UIImage imageNamed:@"JournalShortcutToday"] forState:UIControlStateNormal];
    [todayButton setImage:[UIImage imageNamed:@"JournalShortcutTodaySelected"] forState:UIControlStateHighlighted];
    [todayButton setImage:[UIImage imageNamed:@"JournalShortcutTodaySelected"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [todayButton setExclusiveTouch:YES];
    [todayButton setTag:0];
    [todayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:todayButton];
    
    sevenDayButton = [[IMShortcutButton alloc] initWithFrame:CGRectZero];
    [sevenDayButton setTitle:[NSLocalizedString(@"Past 7 Days", nil) uppercaseString] forState:UIControlStateNormal];
    [sevenDayButton setImage:[UIImage imageNamed:@"JournalShortcut7Days"] forState:UIControlStateNormal];
    [sevenDayButton setImage:[UIImage imageNamed:@"JournalShortcut7DaysSelected"] forState:UIControlStateHighlighted];
    [sevenDayButton setImage:[UIImage imageNamed:@"JournalShortcut7DaysSelected"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [sevenDayButton setExclusiveTouch:YES];
    [sevenDayButton setTag:7];
    [sevenDayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:sevenDayButton];
    
    fourteenDayButton = [[IMShortcutButton alloc] initWithFrame:CGRectZero];
    [fourteenDayButton setTitle:[NSLocalizedString(@"Past 14 days", nil) uppercaseString] forState:UIControlStateNormal];
    [fourteenDayButton setImage:[UIImage imageNamed:@"JournalShortcut14Days"] forState:UIControlStateNormal];
    [fourteenDayButton setImage:[UIImage imageNamed:@"JournalShortcut14DaysSelected"] forState:UIControlStateHighlighted];
    [fourteenDayButton setImage:[UIImage imageNamed:@"JournalShortcut14DaysSelected"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [fourteenDayButton setExclusiveTouch:YES];
    [fourteenDayButton setTag:14];
    [fourteenDayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:fourteenDayButton];
    
    self.tableView.tableHeaderView = headerView;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenStarterTooltip]) {
        [self showTips];
    }
    
    [self reloadViewData:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat buttonWidth = floorf(self.view.frame.size.width/3.0f);
    todayButton.frame = CGRectMake(0.0f, 0.0f, buttonWidth, 119.0f);
    sevenDayButton.frame = CGRectMake(buttonWidth, 0.0f, buttonWidth, 119.0f);
    fourteenDayButton.frame = CGRectMake(buttonWidth*2.0f, 0.0f, buttonWidth, 119.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)reloadViewData:(NSNotification *)note {
    readings = [self fetchReadingData];
    [self refreshView];
}

#pragma mark - UI
- (void)changeProfile:(id)sender {
    
}

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

- (void)showTips {
    IMAppDelegate *appDelegate = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *targetVC = appDelegate.viewController;
    
    IMTooltipViewController *modalView = [[IMTooltipViewController alloc] initWithParentVC:targetVC andDelegate:self];
    IMIntroductionTooltipView *tooltipView = [[IMIntroductionTooltipView alloc] initWithFrame:CGRectZero];
    [modalView setContentView:tooltipView];
    [modalView present];
}

#pragma mark - Table view data source

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
    if(indexPath.row%2 == 0) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row/2 inSection:indexPath.section];
        
        IMJournalTableViewCell *cell = (IMJournalTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"journalTableViewCell" forIndexPath:indexPath];
        
        NSString *key = [[readings allKeys] objectAtIndex:indexPath.row];
        NSDictionary *stats = [readings objectForKey:key];
        
        [cell configureCellForMonth:key withStats:stats];
        
        return cell;
    } else {
        UITableViewCell *cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMJournalSpacerViewCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate functions
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row%2 == 0) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row/2 inSection:indexPath.section];
        NSString *key = [[readings allKeys] objectAtIndex:indexPath.row];
        if(key) {
            NSDictionary *data = [readings objectForKey:key];
            
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
        return 500.0f;
    }
    return 20.0f;
}

#pragma mark - IMTooltipViewControllerDelegate methods
- (void)willDisplayModalView:(IMTooltipViewController *)aModalController {
}

- (void)didDismissModalView:(IMTooltipViewController *)aModalController {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenStarterTooltip];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
