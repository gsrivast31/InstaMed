//
//  IMDayRecordTableViewCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMDayRecordTableViewCell : UITableViewCell

+ (CGFloat)heightForEntry;
- (void)configureCellForEntry:(NSManagedObject*)object hasTop:(BOOL)top hasBottom:(BOOL)bottom withDate:(NSDate*)date withAlpha:(CGFloat)alpha withMetadata:(NSDictionary*)metadata withImage:(UIImage*)image;

// Helpers
+ (CGFloat)additionalHeightWithMetaData:(NSDictionary *)data width:(CGFloat)width;

@end
