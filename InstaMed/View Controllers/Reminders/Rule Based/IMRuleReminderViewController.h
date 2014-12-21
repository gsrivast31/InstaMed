//
//  IMRuleReminderViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMBaseViewController.h"
#import "IMReminderRule.h"
#import "IMReminderBaseViewController.h"

#import "IMCategoryInputView.h"

@interface IMRuleReminderViewController : IMReminderBaseViewController <UITextFieldDelegate, UIAlertViewDelegate, IMAutocompleteBarDelegate, IMCategoryInputViewDelegate>

// Setup
- (id)initWithReminderRule:(IMReminderRule *)rule;

@end
