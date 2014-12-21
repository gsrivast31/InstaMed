//
//  IMTimelineViewCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 23/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMTimelineViewCell : IMGenericTableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UITextView *notesTextView;

// Logic
- (void)setPhotoImage:(UIImage *)image;
- (void)setMetaData:(NSDictionary *)data;
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
          withController:(UIViewController *)controller
               indexPath:(NSIndexPath *)indexPath
            andTableView:(UITableView *)tableView;

// Accessors
- (void)setDate:(NSDate *)aDate;

// Helpers
+ (CGFloat)additionalHeightWithMetaData:(NSDictionary *)data width:(CGFloat)width;

@end
