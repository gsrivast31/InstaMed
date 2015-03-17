//
//  IMReportViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMReport.h"

@interface IMReportViewController : UITableViewController

@property (nonatomic) enum IMReportType reportType;
@property (nonatomic, strong) NSString *viewTitle;

@end
