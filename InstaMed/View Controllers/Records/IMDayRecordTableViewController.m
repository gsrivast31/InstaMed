//
//  IMDayRecordTableViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMDayRecordTableViewController.h"
#import "IMEntryListTableViewController.h"
#import "IMDayRecordTableViewCell.h"
#import "IMCoreDataStack.h"
#import "IMEvent.h"
#import "IMBGReading.h"
#import "IMBPReading.h"
#import "IMCholesterolReading.h"
#import "IMWeightReading.h"
#import "IMActivity.h"
#import "IMMeal.h"
#import "IMMedicine.h"
#import "IMNote.h"

#import "IMEntryActivityInputViewController.h"
#import "IMEntryMealInputViewController.h"
#import "IMEntryMedicineInputViewController.h"
#import "IMEntryBGReadingInputViewController.h"
#import "IMEntryCholesterolInputViewController.h"
#import "IMEntryBPReadingInputViewController.h"
#import "IMEntryWeightInputViewController.h"
#import "IMEntryNoteInputViewController.h"
#import "IMMediaController.h"

#import "CAGradientLayer+IMGradients.h"

@interface IMDayRecordTableViewController () <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
    UISearchController* searchController;
    
    NSArray *sectionStats;
    NSArray *searchResults;
    NSArray *searchResultHeaders;
    NSArray *searchResultSectionStats;

    NSDateFormatter *dateFormatter;
    
    id settingsChangeNotifier;
    id applicationResumeNotifier;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSPredicate *timelinePredicate;
@property (nonatomic, assign) NSInteger relativeDays;

@property (nonatomic, strong) IMViewControllerMessageView *noEntriesMessageView;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation IMDayRecordTableViewController

@synthesize relativeDays = _relativeDays;

#pragma mark - Setup

- (void)setRelativeDays:(NSInteger)days {
    if (self) {
        [self commonInit];
        
        NSDate *fromDate = nil;
        if(days > 0) {
            fromDate = [[[[NSDate date] dateAtStartOfDay] dateBySubtractingDays:days-1] dateAtEndOfDay];
        } else {
            fromDate = [[NSDate date] dateAtStartOfDay];
        }
        self.timelinePredicate = [NSPredicate predicateWithFormat:@"timestamp >= %@", fromDate];
    }
}

- (void)setDateFrom:(NSDate*)fromDate to:(NSDate*)toDate {
    if (self) {
        [self commonInit];
        _relativeDays = -1;
        self.timelinePredicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ && timestamp <= %@", fromDate, toDate];
    }
}

- (void)setTag:(NSString *)tag {
    if (self) {
        [self commonInit];
        _relativeDays = -1;
        
        self.title = [NSString stringWithFormat:@"#%@", tag];
        self.timelinePredicate = [NSPredicate predicateWithFormat:@"ANY tags.nameLC = %@", [tag lowercaseString]];
    }
}

- (void)commonInit {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMMM yyyy"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup our nav bar buttons
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)] animated:NO];
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    [searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = searchController.searchBar;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.delegate = self;
    searchController.searchBar.delegate = self;
    
    self.definesPresentationContext = YES;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self calculateSectionStats];
    
    // Notifications
    
    __weak typeof(self) weakSelf = self;
    
    applicationResumeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:@"applicationResumed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if(strongSelf.relativeDays > -1) {
            [strongSelf reloadViewData:note];
        }
    }];
    settingsChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kSettingsChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf reloadViewData:note];
    }];

    [self updateNavigationBar];
}

- (void)updateNavigationBar {
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
}

- (void) dismissSelf:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Setup other table styling
    if(!self.noEntriesMessageView) {
        self.noEntriesMessageView = [IMViewControllerMessageView addToViewController:self
                                                                           withTitle:NSLocalizedString(@"No Entries", @"Title of message shown when the user has yet to add any entries to their journal")
                                                                          andMessage:NSLocalizedString(@"You currently don't have any entries in your timeline. To add one, tap the + icon.", nil)];
    }
    [self refreshView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:settingsChangeNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationResumeNotifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Logic
- (void)reloadViewData:(NSNotification *)note {

    self.fetchedResultsController = nil;
    [[self.fetchedResultsController fetchRequest] setPredicate:[self timelinePredicate]];
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
    
    [self refreshView];
}

- (void)refreshView {
    // If we're actively searching refresh our data
    if (self.searchControllerWasActive) {
        searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
    
    // Finally, if we have no data hide our tableview
    if([self hasSavedEvents]) {
        self.noEntriesMessageView.alpha = 0.0f;
    } else {
        self.noEntriesMessageView.alpha = 1.0f;
    }
}

- (void)performSearchWithText:(NSString *)searchText {
    NSString *regex = [NSString stringWithFormat:@".*?%@.*?", [searchText lowercaseString]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name MATCHES[cd] %@ OR self.notes MATCHES[cd] %@", regex, regex];
    
    if(predicate) {
        NSMutableArray *newResults = [NSMutableArray array];
        NSMutableArray *newHeaders = [NSMutableArray array];
        if(self.fetchedResultsController && [[self.fetchedResultsController fetchedObjects] count]) {
            for(id<NSFetchedResultsSectionInfo> section in [self.fetchedResultsController sections]) {
                NSArray *matchingObjects = [[section objects] filteredArrayUsingPredicate:predicate];
                if(matchingObjects && [matchingObjects count]) {
                    NSMutableArray *objects = [NSMutableArray array];
                    for(id object in [section objects]) {
                        NSInteger indexOfObject = [matchingObjects indexOfObject:object];
                        BOOL relevant = indexOfObject != NSNotFound;
                        if(![[NSUserDefaults standardUserDefaults] boolForKey:kFilterSearchResultsKey] || ([[NSUserDefaults standardUserDefaults] boolForKey:kFilterSearchResultsKey] && relevant)) {
                            [objects addObject:[NSDictionary dictionaryWithObjectsAndKeys:object, @"object", [NSNumber numberWithBool:relevant], @"relevant", nil]];
                        }
                    }
                    
                    [newHeaders addObject:[section name]];
                    [newResults addObject:objects];
                }
            }
            
            searchResults = newResults;
            searchResultHeaders = newHeaders;
            
            NSMutableArray *stats = [NSMutableArray array];
            for(NSArray *results in searchResults) {
                [stats addObject:[self calculatedStatsForObjects:results]];
            }
            searchResultSectionStats = [NSArray arrayWithArray:stats];
            
            return;
        }
    }
    
    searchResults = nil;
    searchResultHeaders = nil;
    searchResultSectionStats = nil;
}

- (void)calculateSectionStats {
    NSMutableArray *stats = [NSMutableArray array];
    
    if(self.fetchedResultsController && [[self.fetchedResultsController fetchedObjects] count]) {
        for(id<NSFetchedResultsSectionInfo> section in [self.fetchedResultsController sections]) {
            [stats addObject:[self calculatedStatsForObjects:[section objects]]];
        }
    }
    
    sectionStats = stats;
}

- (NSDictionary *)calculatedStatsForObjects:(NSArray *)objects {
    NSInteger activityCount = 0, readingBGCount = 0, mealCount = 0, readingChCount = 0, readingBPCount = 0, readingWeightCount = 0;
    double activityTotal = 0, readingBGTotal = 0, mealTotal = 0, readingChTotal = 0, readingWeightTotal = 0;
    double readingBPLowTotal = 0, readingBPHighTotal = 0;
    
    for(id object in objects) {
        IMEvent *event = nil;
        if([object isKindOfClass:[NSDictionary class]]) {
            event = (IMEvent *)[object valueForKey:@"object"];
        } else {
            event = (IMEvent *)object;
        }
        
        if([event isKindOfClass:[IMBGReading class]]) {
            readingBGCount++;
            readingBGTotal += [[(IMBGReading *)event value] doubleValue];
        } else if([event isKindOfClass:[IMActivity class]]) {
            activityCount++;
            activityTotal += [[(IMActivity *)event minutes] doubleValue];
        } else if([event isKindOfClass:[IMMeal class]]) {
            mealCount++;
            mealTotal += [[(IMMeal *)event grams] doubleValue];
        } else if([event isKindOfClass:[IMCholesterolReading class]]) {
            readingChCount++;
            readingChTotal += [[(IMCholesterolReading *)event value] doubleValue];
        } else if([event isKindOfClass:[IMWeightReading class]]) {
            readingWeightCount++;
            readingWeightTotal += [[(IMWeightReading *)event value] doubleValue];
        } else if([event isKindOfClass:[IMBPReading class]]) {
            readingBPCount++;
            readingBPLowTotal += [[(IMBPReading *)event lowValue] doubleValue];
            readingBPHighTotal += [[(IMBPReading *)event highValue] doubleValue];
        }
    }
    
    // Calculate our reading average
    if(readingBGCount) readingBGTotal /= readingBGCount;
    if(readingChCount) readingChTotal /= readingChCount;
    if(readingWeightCount) readingWeightTotal /= readingWeightCount;
    if(readingBPCount) readingBPLowTotal /= readingBPCount;
    if(readingBPCount) readingBPHighTotal /= readingBPCount;
    
    return @{
             @"bg_reading": [NSNumber numberWithDouble:readingBGTotal],
             @"ch_reading": [NSNumber numberWithDouble:readingChTotal],
             @"bp_low_reading": [NSNumber numberWithDouble:readingBPLowTotal],
             @"bp_high_reading": [NSNumber numberWithDouble:readingBPHighTotal],
             @"activity": [NSNumber numberWithDouble:activityTotal],
             @"meal": [NSNumber numberWithDouble:mealTotal]
             };
}

#pragma mark - UI
- (void)addEvent:(id)sender {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    IMEntryListTableViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"entryListTableViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configureCell:(UITableViewCell *)aCell forTableview:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    if([[aCell class] isEqual:[IMDayRecordTableViewCell class]]) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        IMDayRecordTableViewCell *cell = (IMDayRecordTableViewCell *)aCell;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        BOOL dimCellContents = NO;
        NSManagedObject *object = nil;
        if(searchController.isActive == NO) {
            object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        } else {
            NSArray *section = [searchResults objectAtIndex:indexPath.section];
            NSDictionary *objectData = (NSDictionary *)[section objectAtIndex:indexPath.row];
            object = [objectData valueForKey:@"object"];
            
            dimCellContents = ![[objectData valueForKey:@"relevant"] boolValue];
        }
        
        NSDate *date = (NSDate *)[object valueForKey:@"timestamp"];

        BOOL hasTop = YES;
        BOOL hasBottom = YES;
        
        if (searchController.isActive == NO) {
            if (indexPath.row == 0) {
                hasTop = NO;
            }
            
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
            if (indexPath.row == [sectionInfo numberOfObjects] - 1) {
                hasBottom = NO;
            }
        }
        else {
            hasTop = hasBottom = NO;
        }
    
        CGFloat alpha = 1.0f;
        if (dimCellContents) {
            alpha = 0.35f;
        }
        
        NSDictionary *metadata = [self metaDataForTableView:tableView cellAtIndexPath:indexPath];

        if([[NSUserDefaults standardUserDefaults] boolForKey:kShowInlineImages] && metadata[@"photoPath"]) {
            [[IMMediaController sharedInstance] imageWithFilenameAsync:metadata[@"photoPath"] success:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell configureCellForEntry:object hasTop:hasTop hasBottom:hasBottom withDate:date withAlpha:alpha withMetadata:metadata withImage:image];

                });
            } failure:nil];
        } else {
            [cell configureCellForEntry:object hasTop:hasTop hasBottom:hasBottom withDate:date withAlpha:alpha withMetadata:metadata withImage:nil];
        }        
    }
    /*else if([[aCell class] isEqual:[IMTimelineHeaderViewCell class]])
    {
        IMTimelineHeaderViewCell *cell = (IMTimelineHeaderViewCell *)aCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDate:[self tableView:aTableView titleForHeaderInSection:indexPath.section]];
        
        NSArray *stats = ([self.searchDisplayController isActive]) ? searchResultSectionStats : sectionStats;
        if([stats count] && indexPath.section <= [stats count]-1)
        {
            NSDictionary *section = [stats objectAtIndex:indexPath.section];
            [cell.glucoseStatView setText:[NSString stringWithFormat:@"%@ %@", [glucoseFormatter stringFromNumber:section[@"reading"]], [NSLocalizedString(@"Avg.", @"Abbreviation for average") lowercaseString]]];
            [cell.activityStatView setText:[IMHelper formatMinutes:[[section valueForKey:@"activity"] integerValue]]];
            [cell.mealStatView setText:[NSString stringWithFormat:@"%@ %@", [valueFormatter stringFromNumber:section[@"meal"]], [NSLocalizedString(@"Carbs", nil) lowercaseString]]];
        }
    }*/
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchController setActive:NO];
}

#pragma mark - UISearchControllerDelegate

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchViewController {
    [self performSearchWithText:searchViewController.searchBar.text];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(searchController.isActive == NO) {
        return [[self.fetchedResultsController sections] count];
    } else {
        return [searchResultHeaders count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(searchController.isActive == NO) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        //return [sectionInfo numberOfObjects] + 1;
        return [sectionInfo numberOfObjects];
    } else {
        return [[searchResults objectAtIndex:section] count];
        //return [[searchResults objectAtIndex:section] count]+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMDayRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dayRecordCell" forIndexPath:indexPath];
    [self configureCell:cell forTableview:tableView atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat baseHeight = 60.0f;
    CGFloat height = baseHeight + [IMDayRecordTableViewCell additionalHeightWithMetaData:[self metaDataForTableView:tableView cellAtIndexPath:indexPath] width:self.tableView.bounds.size.width];
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *timestampStr = nil;
    
    if(searchController.isActive == NO) {
        timestampStr = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    } else {
        timestampStr = [searchResultHeaders objectAtIndex:section];
    }
    
    if(timestampStr) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestampStr integerValue]];
        
        if([date isEqualToDate:[[NSDate date] dateWithoutTime]]) {
            return NSLocalizedString(@"Today", nil);
        } else if([date isEqualToDateIgnoringTime:[NSDate dateYesterday]]) {
            return NSLocalizedString(@"Yesterday", nil);
        }
        
        return [dateFormatter stringFromDate:date];
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return ![[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[IMTimelineHeaderViewCell class]];
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
        if(moc) {
            NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSError *error = nil;
            if(object) {
                [moc deleteObject:object];
                [moc save:&error];
                
                [self refreshView];
            }
            
            // Turn off the UITableView's edit mode to avoid having it 'freeze'
            tableView.editing = NO;
            
            if(error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"There was an error while trying to delete this event: %@", nil), [error localizedDescription]]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

#pragma mark - UITableViewDelegate functions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    NSManagedObject *object = nil;
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    if(tableView == self.tableView) {
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        NSArray *section = [searchResults objectAtIndex:indexPath.section];
        NSDictionary *objectData = (NSDictionary *)[section objectAtIndex:indexPath.row];
        object = [objectData valueForKey:@"object"];
    }
    
    if(object) {
        IMEvent* event = (IMEvent*)object;
        
        if ([event isKindOfClass:[IMActivity class]]) {
            IMEntryActivityInputViewController* vc = [[IMEntryActivityInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if ([event isKindOfClass:[IMMeal class]]) {
            IMEntryMealInputViewController* vc = [[IMEntryMealInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if ([event isKindOfClass:[IMBGReading class]]) {
            IMEntryBGReadingInputViewController* vc = [[IMEntryBGReadingInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if ([event isKindOfClass:[IMCholesterolReading class]]) {
            IMEntryCholesterolInputViewController* vc = [[IMEntryCholesterolInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if ([event isKindOfClass:[IMBPReading class]]) {
            IMEntryBPReadingInputViewController* vc = [[IMEntryBPReadingInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if ([event isKindOfClass:[IMWeightReading class]]) {
            IMEntryWeightInputViewController* vc = [[IMEntryWeightInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if ([event isKindOfClass:[IMMedicine class]]) {
            IMEntryMedicineInputViewController* vc = [[IMEntryMedicineInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if ([event isKindOfClass:[IMNote class]]) {
            IMEntryNoteInputViewController* vc = [[IMEntryNoteInputViewController alloc] initWithEvent:event];
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

#pragma mark - Helpers
- (NSDictionary *)metaDataForTableView:(UITableView *)tableView cellAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = nil;
    if(searchController.isActive == NO) {
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        NSArray *section = [searchResults objectAtIndex:indexPath.section];
        object = [[section objectAtIndex:indexPath.row] valueForKey:@"object"];
    }
    
    NSMutableDictionary *metaData = [NSMutableDictionary dictionary];
    NSString *notes = [object valueForKey:@"notes"];
    NSString *photoPath = [object valueForKey:@"photoPath"];
    if(notes) [metaData setObject:notes forKey:@"notes"];
    if(photoPath) [metaData setObject:photoPath forKey:@"photoPath"];
    
    return [NSDictionary dictionaryWithDictionary:metaData];
}

- (BOOL)hasSavedEvents {
    if(self.fetchedResultsController) {
        if([[self.fetchedResultsController fetchedObjects] count]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - NSFetchedResultsControllerDelegate functions

- (NSFetchRequest *)entryListFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IMEvent"];
    [fetchRequest setFetchBatchSize:20];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    
    fetchRequest.predicate = [self timelinePredicate];
    
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self entryListFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forTableview:self.tableView atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self calculateSectionStats];
    [self.tableView endUpdates];
    [self.tableView reloadData];
    
    // Are there any remaining events to use while calculating?
    if(![self hasSavedEvents]) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5
                         animations:^{
                             weakSelf.tableView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

#pragma mark - UIStateRestoration

/* we restore several items for state restoration:
 1) Search controller's active state,
 2) search text,
 3) first responder
 */
static NSString *ViewControllerTitleKey = @"ViewControllerTitleKey";
static NSString *SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
static NSString *SearchBarTextKey = @"SearchBarTextKey";
static NSString *SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchViewController = searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchViewController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchViewController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchViewController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}



@end
