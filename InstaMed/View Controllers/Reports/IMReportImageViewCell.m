//
//  IMReportImageViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 17/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportImageViewCell.h"
#import "IMMediaController.h"
#import <QuartzCore/QuartzCore.h>

#define kBorderWidth 1.0

@implementation IMReportImageViewCell

- (void)addBorder:(UIImageView*)imageView {
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(-kBorderWidth, -kBorderWidth, imageView.frame.size.width + 2*kBorderWidth, imageView.frame.size.height + 2*kBorderWidth);
    
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:kBorderWidth];
    [borderLayer setBorderColor:[[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f] CGColor]];
    [imageView.layer addSublayer:borderLayer];
}

- (void) configureCellForEntry:(NSString *)imagePath {
    __weak typeof(self) weakSelf = self;
    [[IMMediaController sharedInstance] imageWithFilenameAsync:imagePath success:^(UIImage *image) {
        __strong typeof(weakSelf) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.reportImageView.image = image;
            //[strongSelf addBorder:strongSelf.reportImageView];
        });
    } failure:^{
        
    }];
}

@end
