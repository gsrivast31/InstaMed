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

@interface IMJournalViewController : IMBaseTableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate >

// Logic
- (OrderedDictionary *)fetchReadingData;
- (void)addEvent:(id)sender;
- (void)showSideMenu:(id)sender;
- (void)refreshView;

// Helpers
- (NSString *)keyForIndexPath:(NSIndexPath *)aIndexPath;

@end
