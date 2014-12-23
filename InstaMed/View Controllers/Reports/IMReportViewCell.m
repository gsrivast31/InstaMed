//
//  IMReportViewCell.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportViewCell.h"
#import "IMReport.h"
#import "IMMediaController.h"

#import <QuartzCore/QuartzCore.h>
#import "IMImage.h"

#define kBorderWidth 1.0

@interface IMReportViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *reportImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end

@implementation IMReportViewCell

- (void)addBorder {
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(-kBorderWidth, -kBorderWidth, self.reportImage.frame.size.width + 2*kBorderWidth, self.reportImage.frame.size.height + 2*kBorderWidth);
    
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:kBorderWidth];
    [borderLayer setBorderColor:[[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f] CGColor]];
    [self.reportImage.layer addSublayer:borderLayer];
}

- (void)configureCellForEntry:(IMReport *)entry {
    self.title.text = entry.title;
    self.doctorName.text = entry.doctorName;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:entry.date];
    
    self.date.text = [dateFormatter stringFromDate:date];

    NSSet* imagePaths = entry.images;
    if ([imagePaths count]) {
        IMImage* image = (IMImage*)[imagePaths anyObject];
        __weak typeof(self) weakSelf = self;
        [[IMMediaController sharedInstance] imageWithFilenameAsync:image.imagePath success:^(UIImage *image) {
            __strong typeof(weakSelf) strongSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.reportImage.image = image;
            });
        } failure:^{
            
        }];
        
    }
    [self addBorder];
}
- (IBAction)exportReport:(id)sender {
    NSDictionary* info = @{@"title":self.title.text,@"date":self.date.text,@"image":self.reportImage.image};
    [[NSNotificationCenter defaultCenter] postNotificationName:kExportReportNotification object:nil userInfo:info];
}

@end
