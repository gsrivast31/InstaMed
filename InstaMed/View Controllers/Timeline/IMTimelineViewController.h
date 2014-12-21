//
//  IMTimelineViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 05/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "IMHelper.h"
#import "IMBaseViewController.h"
#import "IMReportsViewController.h"

#import "IMAddEntryModalView.h"
#import "IMTimelineViewCell.h"
#import "IMTimelineHeaderViewCell.h"

@class IMDetailViewController;
@interface IMTimelineViewController : IMBaseTableViewController <IMAddEntryModalDelegate, IMReportsDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

// Setup
- (id)initWithRelativeDays:(NSInteger)days;
- (id)initWithDateFrom:(NSDate *)aFromDate to:(NSDate *)aToDate;
- (id)initWithTag:(NSString *)tag;

// Logic
- (void)refreshView;
- (void)performSearchWithText:(NSString *)searchText;
- (void)calculateSectionStats;

// UI
- (void)configureCell:(UITableViewCell *)cell forTableview:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

// Helpers
- (NSDictionary *)metaDataForTableView:(UITableView *)tableView cellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)hasSavedEvents;

@end
