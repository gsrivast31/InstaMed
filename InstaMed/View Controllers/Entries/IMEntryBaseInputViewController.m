//
//  IMEntryBaseInputViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEntryBaseInputViewController.h"

#import "IMEventController.h"
#import "IMReminderController.h"
#import "IMMediaController.h"
#import "IMTagController.h"
#import "IMLocationController.h"
#import "IMEventMapViewController.h"
#import "IMTimeReminderViewController.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

#import "IMEventInputViewCell.h"
#import "IMEventInputTextFieldViewCell.h"
#import "IMEventInputTextViewViewCell.h"
#import "IMEventInputCategoryViewCell.h"
#import "IMEventDateTimeViewCell.h"
#import "IMEventInputLabelViewCell.h"

#import "IMEventPhotoImageView.h"
#import "IMEventLocationMapView.h"
#import "UITextView+Extension.h"

#import "IMCoreDataStack.h"

#import "IMEvent.h"

#define kImageActionSheetTag 0
#define kExistingImageActionSheetTag 1
#define kGeotagActionSheetTag 2
#define kReminderActionSheetTag 3

#define kDeleteAlertViewTag 0
#define kGeoTagAlertViewTag 1

@interface IMEntryBaseInputViewController ()
{
}
@end

@implementation IMEntryBaseInputViewController

#pragma mark - Setup
- (id)init {
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        self.currentPhotoPath = nil;
        self.activeControlIndexPath = nil;
        self.lat = nil, self.lon = nil;
        self.date = [NSDate date];
        
        dummyNotesTextView = [[IMEventNotesTextView alloc] initWithFrame:CGRectZero];
        dummyNotesTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dummyNotesTextView.scrollEnabled = NO;
        dummyNotesTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        dummyNotesTextView.autocorrectionType = UITextAutocorrectionTypeYes;
        dummyNotesTextView.font = [IMFont standardMediumFontWithSize:16.0f];
    }
    return self;
}

- (id)initWithEvent:(IMEvent *)theEvent {
    self = [self init];
    if(self) {
        self.event = theEvent;
        
        self.date = self.event.timestamp;
        notes = self.event.notes;
        self.currentPhotoPath = self.event.photoPath;
        self.lat = self.event.latitude;
        self.lon = self.event.longitude;
    }
    
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.tableView.tintColor = [self tintColor];
    [self.tableView registerClass:[IMEventInputTextViewViewCell class] forCellReuseIdentifier:@"IMEventInputTextViewViewCell"];
    [self.tableView registerClass:[IMEventInputTextFieldViewCell class] forCellReuseIdentifier:@"IMEventTextFieldViewCell"];
    [self.tableView registerClass:[IMEventInputCategoryViewCell class] forCellReuseIdentifier:@"IMEventInputCategoryViewCell"];
    [self.tableView registerClass:[IMEventDateTimeViewCell class] forCellReuseIdentifier:@"IMEventDateTimeViewCell"];
    [self.tableView registerClass:[IMEventInputLabelViewCell class] forCellReuseIdentifier:@"IMEventInputLabelViewCell"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(save:)];

    [self updateNavigationBar];
}

- (void)updateNavigationBar {
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:[self navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"trans"]];
    [self.navigationController.navigationBar setTintColor: [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[IMFont standardDemiBoldFontWithSize:17.0f]}];
}

- (UIImage *)navigationBarBackgroundImage {
    return nil;
}

- (UIColor *)tintColor {
    return nil;
}

#pragma Responders, Events
- (void)dismissSelf {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender {
    [self dismissSelf];
}

- (void)save:(id)sender {
    [self.tableView endEditing:YES];
    
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if (moc) {
        NSError *validationError = [self validationError];
        if (validationError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                message:validationError.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else {
            NSMutableArray *newEvents = [NSMutableArray array];
            
            NSError *saveError = nil;
            IMEvent *event = [self saveEvent:&saveError];
            if(event && !saveError) {
                [newEvents addObject:event];
            }
            
            // If we're editing an event, remove it so that we don't continually create new reminders
            if(self.event) {
                [newEvents removeObject:self.event];
            }
            
            // Iterate over our newly created events and see if any match our rules
            NSArray *rules = [[IMReminderController sharedInstance] fetchAllReminderRules];
            if(rules && [rules count]) {
                for(IMReminderRule *rule in rules) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:rule.predicate];
                    if(predicate) {
                        NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:[newEvents filteredArrayUsingPredicate:predicate]];
                        
                        // If we have a match go ahead and create a reminder
                        if(filteredEvents && [filteredEvents count]) {
                            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMReminder" inManagedObjectContext:moc];
                            IMReminder *newReminder = (IMReminder *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                            newReminder.created = [NSDate date];
                            
                            NSDate *triggerDate = [[filteredEvents objectAtIndex:0] valueForKey:@"timestamp"];
                            
                            newReminder.message = rule.name;
                            if([rule.intervalType integerValue] == kMinuteIntervalType) {
                                newReminder.date = [triggerDate dateByAddingMinutes:[rule.intervalAmount integerValue]];
                            } else if([rule.intervalType integerValue] == kHourIntervalType) {
                                newReminder.date = [triggerDate dateByAddingHours:[rule.intervalAmount integerValue]];
                            } else if([rule.intervalType integerValue] == kDayIntervalType) {
                                newReminder.date = [triggerDate dateByAddingDays:[rule.intervalAmount integerValue]];
                            }
                            
                            newReminder.type = [NSNumber numberWithInteger:kReminderTypeDate];
                            
                            NSError *error = nil;
                            [moc save:&error];
                            
                            if(!error) {
                                [[IMReminderController sharedInstance] setNotificationsForReminder:newReminder];
                                
                                // Notify anyone interested that we've updated our reminders
                                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                            }
                        }
                    }
                }
            }
            
            [self dismissSelf];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                            message:NSLocalizedString(@"We're unable to save your data as a sync is in progress!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Accessors

- (IMEvent *)event {
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(!moc) return nil;
    if(!self.eventOID) return nil;
    
    NSError *error = nil;
    IMEvent *event = (IMEvent *)[moc existingObjectWithID:self.eventOID error:&error];
    if (!event) {
        self.eventOID = nil;
    }
    
    return event;
}

- (void)setEvent:(IMEvent *)theEvent {
    NSError *error = nil;
    if(theEvent.objectID.isTemporaryID && ![theEvent.managedObjectContext obtainPermanentIDsForObjects:@[theEvent] error:&error]) {
        self.eventOID = nil;
    } else {
        self.eventOID = theEvent.objectID;
    }
}

- (IMKeyboardShortcutAccessoryView *)keyboardShortcutAccessoryView {
    if(!_keyboardShortcutAccessoryView) {
        _keyboardShortcutAccessoryView = [[IMKeyboardShortcutAccessoryView alloc] initWithFrame:CGRectZero];
        _keyboardShortcutAccessoryView.delegate = self;
    }
    
    return _keyboardShortcutAccessoryView;
}

#pragma mark - Metadata management
- (void)requestCurrentLocation {
    [self.keyboardShortcutAccessoryView.locationButton showActivityIndicator:YES];
    
    __weak __typeof(self)weakSelf = self;
    [[IMLocationController sharedInstance] fetchUserLocationWithSuccess:^(CLLocation *location) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        strongSelf.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        
        [strongSelf updateKeyboardShortcutButtons];
        [strongSelf.keyboardShortcutAccessoryView.locationButton showActivityIndicator:NO];
        [strongSelf updateUI];
        NSLog(@"got loc: %@", location);
    } failure:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"current loc: %@", error);
        [strongSelf.keyboardShortcutAccessoryView.locationButton showActivityIndicator:NO];
        [strongSelf updateUI];
    }];
}

#pragma mark - Logic

- (NSError *)validationError {
    return nil;
}

- (IMEvent *)saveEvent:(NSError **)error {
    return nil;
}


- (void)discardChanges {
    // Remove any existing photo (provided it's not our original photo)
    if(self.currentPhotoPath && (!self.event || (self.event && ![self.event.photoPath isEqualToString:self.currentPhotoPath]))) {
        [[IMMediaController sharedInstance] deleteImageWithFilename:self.currentPhotoPath success:nil failure:nil];
    }
}

- (void)deleteEvent {
    NSError *error = nil;
    
    IMEvent *event = [self event];
    if(event) {
        NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
        if(moc) {
            [moc deleteObject:event];
            [moc save:&error];
        } else {
            error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    if(!error) {
        [self discardChanges];
        [self dismissSelf];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"There was an error while trying to delete this event: %@", nil), [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)updateUI {
    if(self.currentPhotoPath) {
        IMEventPhotoImageView *photoImageView = [[IMEventPhotoImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 120.0f)];
        [photoImageView.imageView setImage:[[IMMediaController sharedInstance] imageWithFilename:self.currentPhotoPath]];
        [self.tableView setTableHeaderView:photoImageView];
    } else {
        [self.tableView setTableHeaderView:nil];
    }
    
    if(self.lat && self.lon) {
        IMEventLocationMapView *locationMapView = [[IMEventLocationMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 120.0f)];
        [locationMapView setLocation:CLLocationCoordinate2DMake([self.lat doubleValue], [self.lon doubleValue])];
        [self.tableView setTableFooterView:locationMapView];
    } else {
        [self.tableView setTableFooterView:nil];
    }
}

- (void)updateKeyboardShortcutButtons {
    BOOL showTagButton = NO;
    if(self.activeControlIndexPath) {
        IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
        if([cell.control isKindOfClass:[IMEventNotesTextView class]]) {
            showTagButton = YES;
        }
    }
    [self.keyboardShortcutAccessoryView setShowingTagButton:showTagButton];
}

#pragma mark UIImagePickerControllerDelegate

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType fromView:(UIView *)view {
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        if(!imagePickerController) {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
        }
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(!image) image = [info objectForKey:UIImagePickerControllerCropRect];
    
    if(image) {
        NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
        NSString *filename = [NSString stringWithFormat:@"%ld", (long)timestamp];
        
        __weak typeof(self) weakSelf = self;
        [[IMMediaController sharedInstance] saveImage:image withFilename:filename success:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            // Remove any existing photo (provided it's not our original photo)
            if(strongSelf.currentPhotoPath && (!strongSelf.event || (strongSelf.event && ![strongSelf.event.photoPath isEqualToString:strongSelf.currentPhotoPath]))) {
                [[IMMediaController sharedInstance] deleteImageWithFilename:strongSelf.currentPhotoPath success:nil failure:nil];
            }
            
            strongSelf.currentPhotoPath = filename;
            [strongSelf updateUI];
            
        } failure:^(NSError *error) {
            NSLog(@"Image failed with filename: %@. Error: %@", filename, error);
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.keyboardShortcutAccessoryView.autocompleteBar.shouldFetchSuggestions = YES;
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textView.tag inSection:0];
    
    [textView reloadInputViews];
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    [self updateUI];
}

- (void)textViewDidChange:(UITextView *)textView {
    // Determine whether we're currently in tag 'edit mode'
    NSUInteger caretLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
    NSRange range = [[IMTagController sharedInstance] rangeOfTagInString:textView.text withCaretLocation:caretLocation];
    if(range.location != NSNotFound) {
        NSString *currentTag = [textView.text substringWithRange:range];
        currentTag = [currentTag substringFromIndex:1];
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:currentTag];
    } else {
        [[self keyboardShortcutAccessoryView] setShowingAutocompleteBar:NO];
    }
    
    // Update values
    notes = textView.text;
    
    // Finally, update our tableview
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - IMAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(IMAutocompleteBar *)theAutocompleteBar {
    if(self.activeControlIndexPath.row == 0) {
        return [[IMEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:eventFilterType];
    } else {
        return [[IMTagController sharedInstance] fetchAllTags];
    }
    
    return nil;
}

- (void)autocompleteBar:(IMAutocompleteBar *)autocompleteBar didSelectSuggestion:(NSString *)suggestion {
    [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    if([cell.control isKindOfClass:[UITextField class]]) {
        UITextField *activeTextField = (UITextField *)cell.control;
        activeTextField.text = suggestion;
    } else if([cell.control isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)cell.control;
        
        NSUInteger caretLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
        NSRange range = [[IMTagController sharedInstance] rangeOfTagInString:textView.text withCaretLocation:caretLocation];
        if(range.location != NSNotFound) {
            // Only pad our new tag with a space if it's not the end of our note and there isn't already a space following it
            if(range.location + range.length >= textView.text.length || [[textView.text substringWithRange:NSMakeRange(range.location+range.length, 1)] isEqualToString:@" "]) {
                textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location+1, range.length-1) withString:suggestion];
            } else {
                textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location+1, range.length-1) withString:[NSString stringWithFormat:@"%@ ", suggestion]];
            }
            
            notes = textView.text;
        }
    }
    
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
}

#pragma mark - UI

- (void)presentAddReminder:(id)sender {
    UIActionSheet *actionSheet = nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remind me in", nil)
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                destructiveButtonTitle:nil
                                     otherButtonTitles:NSLocalizedString(@"15 minutes", nil), NSLocalizedString(@"30 minutes", nil), NSLocalizedString(@"1 hour", nil), NSLocalizedString(@"2 hours", nil), NSLocalizedString(@"The future", @"An option allow users to be reminded at some point in the future"), nil];
    actionSheet.tag = kReminderActionSheetTag;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (void)presentMediaOptions:(id)sender {
    UIActionSheet *actionSheet = nil;
    if(self.currentPhotoPath) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Remove photo", nil)
                                         otherButtonTitles:NSLocalizedString(@"View photo", nil), nil];
        actionSheet.tag = kExistingImageActionSheetTag;
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
        actionSheet.tag = kImageActionSheetTag;
    }
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (void)presentGeotagOptions:(id)sender {
    if((self.event && [self.event.latitude doubleValue] != 0.0 && [self.event.longitude doubleValue] != 0.0) || ([self.lat doubleValue] != 0.0 && [self.lon doubleValue] != 0.0)) {
        UIActionSheet *actionSheet = nil;
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Remove", nil)
                                         otherButtonTitles:NSLocalizedString(@"View on map", nil), NSLocalizedString(@"Update location", nil), nil];
        actionSheet.tag = kGeotagActionSheetTag;
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    } else {
        [self requestCurrentLocation];
    }
}

- (void)presentTagOptions:(id)sender {
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    if(!cell) {
        [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    
    cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    if([cell.control isKindOfClass:[IMEventNotesTextView class]]) {
        IMEventNotesTextView *activeTextField = (IMEventNotesTextView *)cell.control;
        activeTextField.text = [activeTextField.text stringByAppendingString:@"#"];
    }
}

- (void)triggerDeleteEvent:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Entry", nil)
                                                        message:NSLocalizedString(@"Are you sure you'd like to permanently delete this entry?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alertView.tag = kDeleteAlertViewTag;
    [alertView show];
}

#pragma mark - UIKeyboardShortcutDelegate methods
- (void)keyboardShortcut:(IMKeyboardShortcutAccessoryView *)shortcutView didPressButton:(IMKeyboardShortcutButton *)button
{
    if([button isEqual:[shortcutView locationButton]]) {
        [self presentGeotagOptions:button];
    } else if([button isEqual:[shortcutView deleteButton]]) {
        [self triggerDeleteEvent:button];
    } else if([button isEqual:[shortcutView photoButton]]) {
        [self presentMediaOptions:button];
    } else if([button isEqual:[shortcutView reminderButton]]) {
        [self presentAddReminder:button];
    } else if([button isEqual:[shortcutView tagButton]]) {
        [self presentTagOptions:button];
    }
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kDeleteAlertViewTag && buttonIndex == 1) {
        [self deleteEvent];
    } else if(alertView.tag == kGeoTagAlertViewTag && buttonIndex == 1) {
        [self requestCurrentLocation];
    }
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag == kGeotagActionSheetTag) {
        
        if(buttonIndex == actionSheet.destructiveButtonIndex) {
            self.lat = nil, self.lon = nil;
            self.event.latitude = nil, self.event.longitude = nil;
        } else if(buttonIndex == 1) {
            [self.view endEditing:YES];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lon doubleValue]];
            IMEventMapViewController *vc = [[IMEventMapViewController alloc] initWithLocation:location];
            [self.navigationController pushViewController:vc animated:YES];
        } else if(buttonIndex == 2) {
            [self requestCurrentLocation];
        }
        
    } else if (actionSheet.tag == kReminderActionSheetTag ) {
        NSInteger selectedMins = 0;
        switch(buttonIndex) {
            case 0:
                selectedMins = 15;
                break;
            case 1:
                selectedMins = 30;
                break;
            case 2:
                selectedMins = 60;
                break;
            case 3:
                selectedMins = 120;
                break;
        }
        
        NSDate *date = [[NSDate date] dateByAddingMinutes:selectedMins];
        IMTimeReminderViewController *vc = [[IMTimeReminderViewController alloc] initWithDate:date];
        IMNavigationController *nvc = [[IMNavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    } else {
        
        if(actionSheet.tag == kExistingImageActionSheetTag) {
            if(buttonIndex == actionSheet.destructiveButtonIndex) {
                self.event.photoPath = nil, self.currentPhotoPath = nil;
            } else if(buttonIndex == 1) {
                [self.view endEditing:YES];
                
                UIImage *image = [[IMMediaController sharedInstance] imageWithFilename:self.currentPhotoPath];
                if(image) {
                    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:image];
                    viewController.transitioningDelegate = self;
                    
                    [self presentViewController:viewController animated:YES completion:nil];
                }
            }
        } else {
            if(buttonIndex != actionSheet.cancelButtonIndex && buttonIndex != actionSheet.destructiveButtonIndex) {
                if(buttonIndex == 0) {
                    [self.view endEditing:YES];
                }
            }
            
            if(buttonIndex == 0) {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera fromView:[self.keyboardShortcutAccessoryView photoButton]];
            } else if(buttonIndex == 1) {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromView:[self.keyboardShortcutAccessoryView photoButton]];
            }
        }
    }
    
    [self updateUI];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        UIImageView *imageView = [[self.keyboardShortcutAccessoryView photoButton] fullsizeImageView];
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        UIImageView *imageView = [[self.keyboardShortcutAccessoryView photoButton] fullsizeImageView];
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}

@end
