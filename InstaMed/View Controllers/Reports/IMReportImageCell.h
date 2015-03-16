//
//  IMReportImageCell.h
//  HealthMemoir
//
//  Created by Ranjeet on 3/16/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMReportImageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (void)configureCellWithFileName:(NSString*)fileName;

@end
