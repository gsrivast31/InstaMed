//
//  IMReportImageCell.m
//  HealthMemoir
//
//  Created by Ranjeet on 3/16/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportImageCell.h"
#import "IMMediaController.h"

@implementation IMReportImageCell

- (void)configureCellWithFileName:(NSString *)fileName {
    self.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imageView.layer.borderWidth = 2.0f;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.clipsToBounds = YES;
    
    __weak typeof(self) weakSelf = self;
    [[IMMediaController sharedInstance] imageWithFilenameAsync:fileName success:^(UIImage *image) {
        __strong typeof(weakSelf) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.imageView.image = image;
        });
    } failure:^{
    }];
}

@end
