//
//  IMUserCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMUser;

@interface IMUserCell : UITableViewCell

- (void) configureCellForEntry:(IMUser *)entry;

@end
