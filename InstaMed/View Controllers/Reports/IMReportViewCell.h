//
//  IMReportViewCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMReport;

@interface IMReportViewCell : UITableViewCell

- (void) configureCellForEntry:(IMReport *)entry;

@end
