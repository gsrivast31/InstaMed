//
//  IMBaseViewController
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "TPKeyboardAvoidingTableView.h"

#import "IMUI.h"
#import "IMHelper.h"

@interface IMBaseViewController : UIViewController <UIGestureRecognizerDelegate>
{
    BOOL isVisible;
    BOOL isFirstLoad;
    
    UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer;
}
@property (nonatomic, strong) UIView *activeField;
@property (nonatomic, strong) NSIndexPath *activeControlIndexPath;

// Logic
- (void)reloadViewData:(NSNotification *)note;
- (void)handleBack:(id)sender withSound:(BOOL)playSound;
- (void)handleBack:(id)sender;
- (BOOL)isPresentedModally;
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender;

// Keyboard notifications
- (void)keyboardWillBeShown:(NSNotification *)aNotification;
- (void)keyboardWasShown:(NSNotification *)aNotification;
- (void)keyboardWillBeHidden:(NSNotification *)aNotification;
- (void)keyboardWasHidden:(NSNotification *)aNotification;

// Notifications
- (void)coreDataDidChange:(NSNotification *)note;
- (void)iCloudDataDidChange:(NSNotification *)note;

// Helpers
- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification *)notification;

// Helpers
- (UIView *)dismissableView;

@end

@interface IMBaseTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    BOOL isVisible;
    BOOL isFirstLoad;
    
    UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer;
}
@property (nonatomic, strong) UIView *activeField;
@property (nonatomic, strong) NSIndexPath *activeControlIndexPath;
@property (nonatomic, strong) NSString *screenName;

// Logic
- (void)reloadViewData:(NSNotification *)note;
- (void)handleBack:(id)sender withSound:(BOOL)playSound;
- (void)handleBack:(id)sender;
- (BOOL)isPresentedModally;
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender;

@end
