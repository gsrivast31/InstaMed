//
//  IMJournalTableViewCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMJournalTableViewCell : UITableViewCell

- (void)configureCellForMonth:(NSString*)month withStats:(NSDictionary*)stats;

@end
