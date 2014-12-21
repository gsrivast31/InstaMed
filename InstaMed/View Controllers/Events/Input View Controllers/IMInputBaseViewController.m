//
//  IMInputBaseViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 21/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMInputBaseViewController.h"
#import "IMLocationController.h"
#import "IMEventMapViewController.h"

#import "IMEventPhotoImageView.h"
#import "IMEventLocationMapView.h"

@implementation IMInputBaseViewController
@synthesize event = _event;

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        usingSmartInput = NO;
        self.activeView = NO;
        self.activeControlIndexPath = nil;
        self.currentPhotoPath = nil;
        self.lat = nil, self.lon = nil;
        self.date = [NSDate date];
        
        dummyNotesTextView = [[IMEventNotesTextView alloc] initWithFrame:CGRectZero];
        dummyNotesTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dummyNotesTextView.scrollEnabled = NO;
        dummyNotesTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        dummyNotesTextView.autocorrectionType = UITextAutocorrectionTypeYes;
        dummyNotesTextView.font = [IMFont standardMediumFontWithSize:16.0f];
        
        // If we've been asked to automatically geotag events, kick that off here
        if([[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallyGeotagEvents])
        {
            [self requestCurrentLocation];
        }
    }
    return self;
}
- (id)initWithEvent:(IMEvent *)theEvent
{
    self = [self init];
    if(self)
    {
        self.event = theEvent;
        
        self.date = self.event.timestamp;
        notes = self.event.notes;
        self.currentPhotoPath = self.event.photoPath;
        self.lat = self.event.latitude;
        self.lon = self.event.longitude;
    }
    
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [baseView addSubview:self.tableView];
    
    self.view = baseView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.view.tintColor = [self tintColor];
    
    [self.tableView registerClass:[IMEventInputTextViewViewCell class] forCellReuseIdentifier:@"IMEventInputTextViewViewCell"];
    [self.tableView registerClass:[IMEventInputTextFieldViewCell class] forCellReuseIdentifier:@"IMEventTextFieldViewCell"];
    [self.tableView registerClass:[IMEventInputCategoryViewCell class] forCellReuseIdentifier:@"IMEventInputCategoryViewCell"];
    [self.tableView registerClass:[IMEventDateTimeViewCell class] forCellReuseIdentifier:@"IMEventDateTimeViewCell"];
    [self.tableView registerClass:[IMEventInputLabelViewCell class] forCellReuseIdentifier:@"IMEventInputLabelViewCell"];
    
    [self.tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self updateUI];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
   
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Logic
- (NSError *)validationError
{
    return nil;
}
- (IMEvent *)saveEvent:(NSError **)error
{
    return nil;
}
- (void)discardChanges
{
    // Remove any existing photo (provided it's not our original photo)
    if(self.currentPhotoPath && (!self.event || (self.event && ![self.event.photoPath isEqualToString:self.currentPhotoPath])))
    {
        [[IMMediaController sharedInstance] deleteImageWithFilename:self.currentPhotoPath success:nil failure:nil];
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
- (void)deleteEvent
{
    NSError *error = nil;
    
    IMEvent *event = [self event];
    if(event)
    {
        NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            [moc deleteObject:event];
            [moc save:&error];
        }
        else
        {
            error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    if(!error)
    {
        [self discardChanges];
    
        if([self.parentVC.viewControllers count] == 1)
        {
            [self handleBack:self withSound:NO];
        }
        else
        {
            [self.parentVC removeVC:self];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"There was an error while trying to delete this event: %@", nil), [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)updateUI
{
    if(self.currentPhotoPath)
    {
        IMEventPhotoImageView *photoImageView = [[IMEventPhotoImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 120.0f)];
        [photoImageView.imageView setImage:[[IMMediaController sharedInstance] imageWithFilename:self.currentPhotoPath]];
        [self.tableView setTableHeaderView:photoImageView];
    }
    else
    {
        [self.tableView setTableHeaderView:nil];
    }
    
    if(self.lat && self.lon)
    {
        IMEventLocationMapView *locationMapView = [[IMEventLocationMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 120.0f)];
        [locationMapView setLocation:CLLocationCoordinate2DMake([self.lat doubleValue], [self.lon doubleValue])];
        [self.tableView setTableFooterView:locationMapView];
    }
    else
    {
        [self.tableView setTableFooterView:nil];
    }
}
- (void)updateKeyboardShortcutButtons
{
    BOOL showTagButton = NO;
    if(self.activeControlIndexPath)
    {
        IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
        if([cell.control isKindOfClass:[IMEventNotesTextView class]])
        {
            showTagButton = YES;
        }
    }
    [self.keyboardShortcutAccessoryView setShowingTagButton:showTagButton];
}

#pragma mark - Photograph logic
- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType fromView:(UIView *)view
{
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        if(!imagePickerController)
        {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
        }
        imagePickerController.sourceType = sourceType;
        
        if (imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            CGRect r = [self.parentVC.view convertRect:CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 1.0f, 1.0f) fromView:view];
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
            [popover setDelegate:self.parentVC];
            
            self.parentVC.popoverVC = popover;
            [popover presentPopoverFromRect:r inView:self.parentVC.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
        else
        {
            [self.parentViewController presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(!image) image = [info objectForKey:UIImagePickerControllerCropRect];
    
    if(image)
    {
        NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
        NSString *filename = [NSString stringWithFormat:@"%ld", (long)timestamp];
        
        __weak typeof(self) weakSelf = self;
        [[IMMediaController sharedInstance] saveImage:image withFilename:filename success:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            // Remove any existing photo (provided it's not our original photo)
            if(strongSelf.currentPhotoPath && (!strongSelf.event || (strongSelf.event && ![strongSelf.event.photoPath isEqualToString:strongSelf.currentPhotoPath])))
            {
                [[IMMediaController sharedInstance] deleteImageWithFilename:strongSelf.currentPhotoPath success:nil failure:nil];
            }
            
            strongSelf.currentPhotoPath = filename;
            [strongSelf updateUI];
            
        } failure:^(NSError *error) {
            NSLog(@"Image failed with filename: %@. Error: %@", filename, error);
        }];
        
        if (imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self.parentVC closeActivePopoverController];
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.parentVC closeActivePopoverController];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UI
- (void)didBecomeActive
{
    [self updateUI];
    
    if(!self.event && !self.activeControlIndexPath)
    {
        self.activeControlIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    if(self.activeControlIndexPath)
    {
        IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
        [cell.control becomeFirstResponder];
    }
    
    self.activeView = YES;
}
- (void)willBecomeInactive
{
    isFirstLoad = NO;
    [self.view endEditing:YES];
    
    self.activeView = NO;
}
- (UIColor *)tintColor
{
    return nil;
}
- (UIImage *)navigationBarBackgroundImage
{
    return nil;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if([cell respondsToSelector:@selector(control)])
    {
        [cell.control becomeFirstResponder];
    }
    
    if(indexPath.row == self.datePickerIndexPath.row)
    {
        [self.tableView beginUpdates];
        
        if (self.datePickerVisible)
        {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row+1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row+1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.datePickerVisible = !self.datePickerVisible;
        [self.tableView endUpdates];
    }
}
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    if(self.datePickerVisible && indexPath.row == self.datePickerIndexPath.row+1)
    {
        return 220.0f;
    }
    
    return height;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.keyboardShortcutAccessoryView.autocompleteBar.shouldFetchSuggestions = YES;
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textView.tag inSection:0];
    
    [textView reloadInputViews];
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    [self updateUI];
}
- (void)textViewDidChange:(UITextView *)textView
{
    // Determine whether we're currently in tag 'edit mode'
    NSUInteger caretLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
    NSRange range = [[IMTagController sharedInstance] rangeOfTagInString:textView.text withCaretLocation:caretLocation];
    if(range.location != NSNotFound)
    {
        NSString *currentTag = [textView.text substringWithRange:range];
        currentTag = [currentTag substringFromIndex:1];
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:currentTag];
    }
    else
    {
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.keyboardShortcutAccessoryView.autocompleteBar.shouldFetchSuggestions = YES;
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    
    [textField reloadInputViews];
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    [self updateUI];
}

#pragma mark - IMAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(IMAutocompleteBar *)autocompleteBar
{
    return nil;
}
- (void)autocompleteBar:(IMAutocompleteBar *)autocompleteBar didSelectSuggestion:(NSString *)suggestion
{
    [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    if([cell.control isKindOfClass:[UITextField class]])
    {
        UITextField *activeTextField = (UITextField *)cell.control;
        activeTextField.text = suggestion;
    }
    else if([cell.control isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)cell.control;
        
        NSUInteger caretLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
        NSRange range = [[IMTagController sharedInstance] rangeOfTagInString:textView.text withCaretLocation:caretLocation];
        if(range.location != NSNotFound)
        {
            // Only pad our new tag with a space if it's not the end of our note and there isn't already a space following it
            if(range.location + range.length >= textView.text.length || [[textView.text substringWithRange:NSMakeRange(range.location+range.length, 1)] isEqualToString:@" "])
            {
                textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location+1, range.length-1) withString:suggestion];
            }
            else
            {
                textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location+1, range.length-1) withString:[NSString stringWithFormat:@"%@ ", suggestion]];
            }
            
            //textViewHeight = textView.intrinsicContentSize.height;
            notes = textView.text;
            
            //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
}
- (void)presentTagOptions:(id)sender
{
    IMEventInputViewCell *cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    if(!cell)
    {
        [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    cell = (IMEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    if([cell.control isKindOfClass:[IMEventNotesTextView class]])
    {
        IMEventNotesTextView *activeTextField = (IMEventNotesTextView *)cell.control;
        activeTextField.text = [activeTextField.text stringByAppendingString:@"#"];
    }
}

#pragma mark - Metadata management
- (void)requestCurrentLocation
{
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

#pragma mark - Accessors
- (IMEvent *)event
{
    NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
    if(!moc) return nil;
    if(!self.eventOID) return nil;
    
    NSError *error = nil;
    IMEvent *event = (IMEvent *)[moc existingObjectWithID:self.eventOID error:&error];
    if (!event)
    {
        self.eventOID = nil;
    }
    
    return event;
}
- (void)setEvent:(IMEvent *)theEvent
{
    NSError *error = nil;
    if(theEvent.objectID.isTemporaryID && ![theEvent.managedObjectContext obtainPermanentIDsForObjects:@[theEvent] error:&error])
    {
        self.eventOID = nil;
    }
    else
    {
        self.eventOID = theEvent.objectID;
    }
}
- (IMKeyboardShortcutAccessoryView *)keyboardShortcutAccessoryView
{
    if(!_keyboardShortcutAccessoryView)
    {
        _keyboardShortcutAccessoryView = [[IMKeyboardShortcutAccessoryView alloc] initWithFrame:CGRectZero];
        _keyboardShortcutAccessoryView.delegate = self;
    }
    
    return _keyboardShortcutAccessoryView;
}

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    self.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    
    [manager stopUpdatingLocation];
    [self updateUI];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kDeleteAlertViewTag && buttonIndex == 1)
    {
        [self deleteEvent];
    }
    else if(alertView.tag == kGeoTagAlertViewTag && buttonIndex == 1)
    {
        [self requestCurrentLocation];
    }
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kGeotagActionSheetTag)
    {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            self.lat = nil, self.lon = nil;
            self.event.latitude = nil, self.event.longitude = nil;
        }
        else if(buttonIndex == 1)
        {
            [self.view endEditing:YES];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lon doubleValue]];
            IMEventMapViewController *vc = [[IMEventMapViewController alloc] initWithLocation:location];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(buttonIndex == 2)
        {
            [self requestCurrentLocation];
        }
    }
    else
    {
        if(actionSheet.tag == kExistingImageActionSheetTag)
        {
            if(buttonIndex == actionSheet.destructiveButtonIndex)
            {
                self.event.photoPath = nil, self.currentPhotoPath = nil;
            }
            else if(buttonIndex == 1)
            {
                [self.view endEditing:YES];
                
                UIImage *image = [[IMMediaController sharedInstance] imageWithFilename:self.currentPhotoPath];
                if(image)
                {
                    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:image];
                    viewController.transitioningDelegate = self;
                    
                    [self presentViewController:viewController animated:YES completion:nil];
                }
            }
        }
        else
        {
            if(buttonIndex != actionSheet.cancelButtonIndex && buttonIndex != actionSheet.destructiveButtonIndex)
            {
                if(buttonIndex == 0)
                {
                    [self.view endEditing:YES];
                }
            }
            
            if(buttonIndex == 0)
            {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera fromView:[self.keyboardShortcutAccessoryView photoButton]];
            }
            else if(buttonIndex == 1)
            {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromView:[self.keyboardShortcutAccessoryView photoButton]];
            }
        }
    }
    
    [self updateUI];
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class])
    {
        UIImageView *imageView = [[self.keyboardShortcutAccessoryView photoButton] fullsizeImageView];
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:TGRImageViewController.class])
    {
        UIImageView *imageView = [[self.keyboardShortcutAccessoryView photoButton] fullsizeImageView];
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}

#pragma mark - UIKeyboardShortcutDelegate methods
- (void)keyboardShortcut:(IMKeyboardShortcutAccessoryView *)shortcutView didPressButton:(IMKeyboardShortcutButton *)button
{
    if([button isEqual:[shortcutView locationButton]])
    {
        [(IMInputParentViewController *)self.parentViewController presentGeotagOptions:button];
    }
    else if([button isEqual:[shortcutView deleteButton]])
    {
        [self triggerDeleteEvent:button];
    }
    else if([button isEqual:[shortcutView photoButton]])
    {
        [(IMInputParentViewController *)self.parentViewController presentMediaOptions:button];
    }
    else if([button isEqual:[shortcutView reminderButton]])
    {
        [(IMInputParentViewController *)self.parentViewController presentAddReminder:button];
    }
    else if([button isEqual:[shortcutView tagButton]])
    {
        [self presentTagOptions:button];
    }
}

#pragma mark - UINavigationControllerDelegate methods
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    self.parentVC = (IMInputParentViewController *)parent;
    if(parent && self.activeView)
    {
        [self didBecomeActive];
    }
}

@end
