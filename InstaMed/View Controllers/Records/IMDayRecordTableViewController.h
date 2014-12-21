//
//  IMDayRecordTableViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMDayRecordTableViewController : UITableViewController

// Setup
- (void)setDateFrom:(NSDate*)fromDate to:(NSDate*)toDate;
- (void)setRelativeDays:(NSInteger)days;
- (void)setTag:(NSString *)tag;

@end
