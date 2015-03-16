//
//  IMSlider.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 12/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMSliderPopoverView;
@interface IMSlider : UISlider
@end

@interface IMSliderPopoverView : UIView
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) float value;

// Logic
- (void)setValue:(float)aValue;

@end
