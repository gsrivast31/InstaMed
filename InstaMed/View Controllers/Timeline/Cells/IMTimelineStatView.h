//
//  IMTimelineStatView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/11/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMTimelineStatView.h"

@interface IMTimelineStatView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

// Accessors
- (void)setImage:(UIImage *)image;
- (void)setText:(NSString *)text;
@end