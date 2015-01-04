//
//  IMAnalyticsDateTableViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 28/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAnalyticsDateTableViewController.h"
#import "IMAnalyticsBaseNavigationController.h"
#import "IMAnalyticsCarbsChartViewController.h"

#import "IMAnalyticsDateEntry.h"

#import "CAGradientLayer+IMGradients.h"

#define kDatePickerTag 100

static NSString *kEntryCellID = @"entryCell";
static NSString *kDatePickerCellID = @"datePickerCell";

@interface IMAnalyticsDateTableViewController (){
    NSArray* reportData;
}

@property (strong, nonatomic) NSMutableArray *entries;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;

@end

@implementation IMAnalyticsDateTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Analytics";
    
    if(!self.navigationItem.leftBarButtonItem) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setImage:[[UIImage imageNamed:@"NavBarIconBack.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [backButton setTitle:self.navigationItem.backBarButtonItem.title forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10.0f, 0, 0)];
        [backButton setAdjustsImageWhenHighlighted:NO];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(proceed:)];

    CAGradientLayer *backgroundLayer = [CAGradientLayer sideGradientLayer];
    backgroundLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:backgroundLayer atIndex:0];
    [self.tableView.layer insertSublayer:backgroundLayer atIndex:0];

    [self createDateFormatter];
    [self createEntryData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createDateFormatter {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
}

- (void)createEntryData {
    if (!self.entries){
        self.entries = [[NSMutableArray alloc] init];
    }

    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMToday]];
    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMLastWeek]];
    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMLast2Weeks]];
    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMThisMonth]];
    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMLastMonth]];
    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMLast3Months]];
    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMLast6Months]];
    [self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMCustomDate]];
    //[self.entries addObject:[[IMAnalyticsDateEntry alloc] initWithType:IMCustomRange]];
}

- (void)dismissSelf:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)proceed:(id)sender {
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath == nil) {
        return;
    }
    IMAnalyticsDateEntry* entry = self.entries[indexPath.row];
    if ([entry dateString] && ![[entry dateString] isEqualToString:@""]) {
        [self showAnalytics:entry];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = [self.entries count];
    if ([self datePickerIsShown]) {
        rows++;
    }
    return rows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    if ([self datePickerIsShown] && self.datePickerIndexPath.row == indexPath.row) {
        cell = [self createPickerCell:[NSDate date]];
    } else if ([self datePickerIsShown] && indexPath.row > self.datePickerIndexPath.row ) {
        IMAnalyticsDateEntry* entry = self.entries[indexPath.row - 1];
        cell = [self createEntryCell:entry];
    } else {
        IMAnalyticsDateEntry* entry = self.entries[indexPath.row];
        cell = [self createEntryCell:entry];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (UITableViewCell *)createEntryCell:(IMAnalyticsDateEntry *)entry {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kEntryCellID];
    cell.textLabel.text = entry.title;
    cell.detailTextLabel.text = [entry dateString];
    return cell;
}

- (UITableViewCell *)createPickerCell:(NSDate *)date {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[cell viewWithTag:kDatePickerTag];
    [targetedDatePicker setDate:date animated:NO];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = self.tableView.rowHeight;
    if ([self datePickerIsShown] && (self.datePickerIndexPath.row == indexPath.row)){
        rowHeight = 164.0f;
    } else {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat screenHeight = screenRect.size.height - navigationBarHeight - statusBarHeight;
        rowHeight = MAX(50.0f, screenHeight/(CGFloat)[self.entries count]);
    }
    
    return rowHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMAnalyticsDateEntry *entry = self.entries[indexPath.row];
    if (entry.type == IMCustomDate || entry.type == IMCustomRange) {
        [self.tableView beginUpdates];
        
        if ([self datePickerIsShown] && (self.datePickerIndexPath.row - 1 == indexPath.row)){
            [self hideExistingPicker];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }else {
            NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];
            if ([self datePickerIsShown]){
                [self hideExistingPicker];
            }
            [self showNewPickerAtIndex:newPickerIndexPath];
            self.datePickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];
        }
        
        [self.tableView endUpdates];
    } else {
        [self showAnalytics:entry];
    }
}

- (void)showAnalytics:(IMAnalyticsDateEntry*)entry {
    [self fetchReportData:entry.fromDate toDate:entry.toDate];
    IMAnalyticsBaseNavigationController* navController = [[IMAnalyticsBaseNavigationController alloc] initWithRootViewController:[[IMAnalyticsCarbsChartViewController alloc] initWithData:reportData from:entry.fromDate to:entry.toDate]];
    [navController setData:reportData from:entry.fromDate to:entry.toDate];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)hideExistingPicker {
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    self.datePickerIndexPath = nil;
}

- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath {
    
    NSIndexPath *newIndexPath;

    if (([self datePickerIsShown]) && (self.datePickerIndexPath.row < selectedIndexPath.row)){
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
    }else {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row  inSection:0];
    }
    
    return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)fetchReportData:(NSDate*)fromDate toDate:(NSDate*)toDate {
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        NSDate *fetchFromDate = [fromDate dateAtStartOfDay];
        NSDate *fetchToDate = [toDate dateAtEndOfDay];
        
        if(fetchFromDate) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMEvent" inManagedObjectContext:moc];
            [fetchRequest setEntity:entity];
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor];
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
            
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"timestamp >= %@ && timestamp <= %@ && userGuid = %@", fetchFromDate, fetchToDate, currentUserGuid]];
            
            NSError *error = nil;
            reportData = [moc executeFetchRequest:fetchRequest error:&error];
            
            if(error) {
                reportData = nil;
            }
        }
    }
}

- (BOOL)datePickerIsShown {
    return self.datePickerIndexPath != nil;
}

- (IBAction)dateChanged:(id)sender {
    NSIndexPath *parentCellIndexPath = nil;
    UIDatePicker* datePicker = (UIDatePicker*)sender;
    
    if ([self datePickerIsShown]){
        parentCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }else {
        return;
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:parentCellIndexPath];
    IMAnalyticsDateEntry *entry = self.entries[parentCellIndexPath.row];
    
    if (entry.type == IMCustomDate) {
        entry.fromDate = [datePicker.date dateAtStartOfDay];
        entry.toDate = [datePicker.date dateAtEndOfDay];
        [self.entries setObject:entry atIndexedSubscript:parentCellIndexPath.row];
        cell.detailTextLabel.text = [entry dateString];
    }
}


@end
