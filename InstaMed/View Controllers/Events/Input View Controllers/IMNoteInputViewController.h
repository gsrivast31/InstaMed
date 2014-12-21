//
//  IMNoteInputViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMInputBaseViewController.h"
#import "IMNote.h"

@interface IMNoteInputViewController : IMInputBaseViewController

// Setup
- (id)init;
- (id)initWithEvent:(IMEvent *)aEvent;

// UI
- (void)changeDate:(id)sender;
- (void)configureAppearanceForTableViewCell:(IMEventInputViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
