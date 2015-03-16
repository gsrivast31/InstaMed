//
//  IMEntryBaseInputViewController.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 21/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMKeyboardShortcutAccessoryView.h"

@class IMEvent;
@class IMEventNotesTextView;
@class IMKeyboardShortcutAccessoryView;

@interface IMEntryBaseInputViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, IMKeyboardShortcutDelegate, IMAutocompleteBarDelegate>

{
    UIImagePickerController *imagePickerController;
    NSString *notes;
    IMEventNotesTextView *dummyNotesTextView;
    EventFilterType eventFilterType;
}

@property (nonatomic, strong) IMEvent *event;

@property (nonatomic, strong) NSManagedObjectID *eventOID;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSString *currentPhotoPath;
@property (nonatomic, strong) NSNumber *lat, *lon;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) IMKeyboardShortcutAccessoryView *keyboardShortcutAccessoryView;

@property (nonatomic, strong) NSIndexPath *activeControlIndexPath;

- (id)initWithEvent:(IMEvent *)theEvent;

- (UIImage *)navigationBarBackgroundImage;
- (UIColor *)tintColor;
- (NSError *)validationError;
- (IMEvent *)saveEvent:(NSError **)error;
- (void)updateUI;

@end
