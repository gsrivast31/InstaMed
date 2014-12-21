//
//  IMJournalViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 30/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderedDictionary.h"

#import "IMBaseViewController.h"
#import "IMAddEntryModalView.h"

@interface IMJournalViewController : IMBaseTableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, IMTooltipViewControllerDelegate, IMAddEntryModalDelegate>

// Logic
- (OrderedDictionary *)fetchReadingData;
- (void)addEvent:(id)sender;
- (void)showSideMenu:(id)sender;
- (void)refreshView;

// UI
- (void)showTips;

// Helpers
- (NSString *)keyForIndexPath:(NSIndexPath *)aIndexPath;

@end
