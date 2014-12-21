//
//  IMInputBaseViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"
#import "UITextView+Extension.h"

#import "IMBaseViewController.h"
#import "IMInputParentViewController.h"
#import "IMKeyboardShortcutAccessoryView.h"
#import "IMUI.h"

#import "IMEventController.h"
#import "IMTagController.h"
#import "IMMediaController.h"

#import "IMEventInputViewCell.h"
#import "IMEventInputCategoryViewCell.h"
#import "IMEventDateTimeViewCell.h"
#import "IMEventInputLabelViewCell.h"
#import "IMEvent.h"

#define kImageActionSheetTag 0
#define kExistingImageActionSheetTag 1
#define kGeotagActionSheetTag 2
#define kReminderActionSheetTag 3

#define kDeleteAlertViewTag 0
#define kGeoTagAlertViewTag 1

@class IMInputParentViewController;
@interface IMInputBaseViewController : IMBaseTableViewController <CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, IMAutocompleteBarDelegate, IMKeyboardShortcutDelegate, UIViewControllerTransitioningDelegate>
{
@protected
    UIImagePickerController *imagePickerController;
    NSString *notes;
    IMEventNotesTextView *dummyNotesTextView;
    
    BOOL usingSmartInput;
}
@property (nonatomic, strong) IMEvent *event;
@property (nonatomic, strong) NSManagedObjectID *eventOID;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IMKeyboardShortcutAccessoryView *keyboardShortcutAccessoryView;
@property (nonatomic, weak) IMInputParentViewController *parentVC;

@property (nonatomic, strong) NSString *currentPhotoPath;
@property (nonatomic, strong) NSNumber *lat, *lon;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign) BOOL activeView;
@property (nonatomic, assign) BOOL datePickerVisible;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

// Setup
- (id)init;
- (id)initWithEvent:(IMEvent *)aEvent;

// Logic
- (void)didBecomeActive;
- (void)willBecomeInactive;
- (void)discardChanges;
- (NSError *)validationError;
- (IMEvent *)saveEvent:(NSError **)error;
- (void)updateUI;
- (void)updateKeyboardShortcutButtons;

// UI
- (void)triggerDeleteEvent:(id)sender;
- (UIImage *)navigationBarBackgroundImage;
- (UIColor *)tintColor;

// Metadata
- (void)requestCurrentLocation;
- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType fromView:(UIView *)view;

@end
