//
//  IMInputBaseViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <CoreLocation/CoreLocation.h>

#import "IMUI.h"
#import "IMAppDelegate.h"
#import "IMBaseViewController.h"
#import "IMEventController.h"
#import "IMTagController.h"
#import "IMMediaController.h"
#import "IMTimeReminderViewController.h"

#import "IMInputBaseViewController.h"
#import "IMEventInputViewCell.h"
#import "IMEventInputTextFieldViewCell.h"
#import "IMEventInputTextViewViewCell.h"
#import "TPKeyboardAvoidingScrollView.h"

@class IMInputBaseViewController;
@interface IMInputParentViewController : IMBaseViewController <UIActionSheetDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) IMEvent *event;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic) NSInteger eventType;

@property (nonatomic, strong) UIPopoverController *popoverVC;

// Setup
- (id)initWithEventType:(NSInteger)eventType;
- (id)initWithEvent:(IMEvent *)aEvent;
- (id)initWithMedicineAmount:(NSNumber *)amount;

// Logic
- (void)saveEvent:(id)sender;
- (void)deleteEvent:(id)sender;
- (void)discardChanges:(id)sender;
- (void)activateTargetViewController;
- (void)addVC:(UIViewController *)vc;
- (void)removeVC:(UIViewController *)vc;

// UI
- (void)presentAddReminder:(id)sender;
- (void)presentMediaOptions:(id)sender;
- (void)presentGeotagOptions:(id)sender;
- (void)updateNavigationBar;

// UIPopoverController logic
- (void)closeActivePopoverController;

@end
