//
//  IMMealInputViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 05/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMInputBaseViewController.h"

#import "IMMeal.h"

@interface IMMealInputViewController : IMInputBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

// UI
- (void)changeDate:(id)sender;
- (void)configureAppearanceForTableViewCell:(IMEventInputViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
