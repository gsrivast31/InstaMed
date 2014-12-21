//
//  IMReportsViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMBaseViewController.h"
#import "IMDatePickerController.h"

@class IMReportsViewController;
@protocol IMReportsDelegate <NSObject>

- (BOOL)shouldDismissReportsOnRotation:(IMReportsViewController *)controller;
- (void)didDismissReportsController:(IMReportsViewController *)controller;

@end

@class IMDateButton;
@interface IMReportsViewController : IMBaseViewController <UIScrollViewDelegate, IMDatePickerDelegate>
@property (nonatomic, weak) id<IMReportsDelegate> delegate;

// Setup
- (id)initFromDate:(NSDate *)aFromDate toDate:(NSDate *)aToDate;

// Logic
- (void)didSelectReport:(UIButton *)sender;
- (void)setDateForReportRange:(id)sender;

@end
