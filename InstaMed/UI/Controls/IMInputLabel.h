//
//  IMInputLabel.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 02/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMInputLabel;
@protocol IMInputLabelDelegate
- (void)inputLabelDidBeginEditing:(IMInputLabel *)inputLabel;

@end

@interface IMInputLabel : UILabel
@property (nonatomic, assign) id<IMInputLabelDelegate> delegate;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UIView *inputAccessoryView;

@end
