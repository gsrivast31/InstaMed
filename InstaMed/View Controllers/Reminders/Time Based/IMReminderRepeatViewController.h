//
//  IMReminderRepeatViewController.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 02/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMUI.h"

@protocol IMReminderRepeatDelegate <NSObject>
- (void)setReminderDays:(NSInteger)days;
@end

@interface IMReminderRepeatViewController : IMBaseTableViewController
@property (nonatomic, assign) id<IMReminderRepeatDelegate> delegate;

// Setup
- (id)initWithFlags:(NSInteger)flags;

@end