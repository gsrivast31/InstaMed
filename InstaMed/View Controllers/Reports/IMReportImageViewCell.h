//
//  IMReportImageViewCell.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 17/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMReportImageViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *reportImageView;
- (void) configureCellForEntry:(NSString *)imagePath;

@end
