//
//  IMMedicineInputViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 05/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMInputBaseViewController.h"

#import "IMMedicine.h"
#import "IMCategoryInputView.h"

@interface IMMedicineInputViewController : IMInputBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, IMCategoryInputViewDelegate>
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger type;

// Setup
- (id)initWithAmount:(NSNumber *)amount;

// UI
- (void)changeDate:(id)sender;
- (void)configureAppearanceForTableViewCell:(IMEventInputViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
