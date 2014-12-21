//
//  IMDatePickerController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMDatePickerController;
@protocol IMDatePickerDelegate <NSObject>

- (void)datePicker:(IMDatePickerController *)controller didSelectDate:(NSDate *)date;

@end

@interface IMDatePickerController : UIView
@property (nonatomic, weak) id<IMDatePickerDelegate> delegate;

// Setup
- (id)initWithFrame:(CGRect)frame andDate:(NSDate *)date;

// Logic
- (void)present;
- (void)dismiss;

@end
