//
//  IMInputParentViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IMInputParentViewController.h"
#import "IMEventMapViewController.h"
#import "IMReminderController.h"

#import "IMMedicineInputViewController.h"
#import "IMMealInputViewController.h"
#import "IMBGInputViewController.h"
#import "IMActivityInputViewController.h"
#import "IMNoteInputViewController.h"

#define kDragBuffer 15.0f

@interface IMInputParentViewController ()
{
    IMEventNotesTextView *notesTextView;
    UIImageView *addEntryBubbleImageView;
    
    CGPoint scrollVelocity;
    
    CGPoint originalContentOffset;
    BOOL isAddingQuickEntry;
    BOOL isAnimatingAddEntry;
    BOOL isBeingPopped;
}
@property (nonatomic, assign) NSUInteger prerotationIndex;
@property (nonatomic, assign) NSUInteger currentIndex;

// Setup
- (void)commonInit;

// Logic
- (void)layoutViewControllers;

// Helpers
- (IMInputBaseViewController *)targetViewController;

@end

@implementation IMInputParentViewController
@synthesize moc = _moc;
@synthesize event = _event;

#pragma mark - Setup
- (id)initWithEventType:(NSInteger)eventType
{
    self = [super init];
    if (self)
    {
        [self commonInit];
        
        self.eventType = eventType;
    }
    return self;
}
- (id)initWithEvent:(IMEvent *)aEvent
{
    _event = aEvent;
    
    self = [super init];
    if(self)
    {
        [self commonInit];
        
        IMInputBaseViewController *vc = nil;
        if([aEvent isKindOfClass:[IMMedicine class]])
        {
            vc = [[IMMedicineInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[IMReading class]])
        {
            vc = [[IMBGInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[IMMeal class]])
        {
            vc = [[IMMealInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[IMActivity class]])
        {
            vc = [[IMActivityInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[IMNote class]])
        {
            vc = [[IMNoteInputViewController alloc] initWithEvent:aEvent];
        }
        [self addVC:vc];
    }
    
    return self;
}
- (id)initWithMedicineAmount:(NSNumber *)amount
{
    self = [super init];
    if (self)
    {
        [self commonInit];
        
        IMMedicineInputViewController *vc = [[IMMedicineInputViewController alloc] initWithAmount:amount];
        [self addVC:vc];
    }
    return self;
}
- (void)commonInit
{
    isAddingQuickEntry = NO;
    isAnimatingAddEntry = NO;
    isBeingPopped = NO;
    
    self.viewControllers = [NSMutableArray array];
    self.currentIndex = 0;
    self.prerotationIndex = 0;
    
    // Setup our scroll view
    if(!self.scrollView)
    {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.scrollView.delegate = self;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.directionalLockEnabled = YES;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
    }
    
    // Setup notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentMediaOptions:)
                                                 name:@"presentMediaOptions" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentGeotagOptions:)
                                                 name:@"presentGeotagOptions" object:nil];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(saveEvent:)];
    [rightBarButtonItems addObject:saveBarButtonItem];
    
    UIBarButtonItem *reminderBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"KeyboardShortcutReminderIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentAddReminder:)];
    [rightBarButtonItems addObject:reminderBarButtonItem];
    
    UIBarButtonItem *locationBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"KeyboardShortcutLocationIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentGeotagOptions:)];
    [rightBarButtonItems addObject:locationBarButtonItem];
    
    UIBarButtonItem *photoBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"KeyboardShortcutPhotoIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentMediaOptions:)];
    [rightBarButtonItems addObject:photoBarButtonItem];
    
    if(self.event)
    {
        UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"KeyboardShortcutDeleteIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(deleteEvent:)];
        [rightBarButtonItems addObject:deleteBarButtonItem];
    }
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:NO];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    
    IMInputBaseViewController *vc = nil;
    if(self.eventType == 0)
    {
        vc = [[IMMedicineInputViewController alloc] init];
    }
    else if(self.eventType == 1)
    {
        vc = [[IMBGInputViewController alloc] init];
    }
    else if(self.eventType == 2)
    {
        vc = [[IMMealInputViewController alloc] init];
    }
    else if(self.eventType == 3)
    {
        vc = [[IMActivityInputViewController alloc] init];
    }
    else if(self.eventType == 4)
    {
        vc = [[IMNoteInputViewController alloc] init];
    }
    [self addVC:vc];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length);
    
    if(!self.event && ![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenAddDragUIHint] && [self.viewControllers count])
    {
        IMInputBaseViewController *inputVC = (IMInputBaseViewController *)self.viewControllers[0];
        if(inputVC)
        {
            IMUIHintView *hintView = [[IMUIHintView alloc] initWithFrame:self.scrollView.frame text:NSLocalizedString(@"Drag left to add additional entries", nil) presentationCallback:^{
                inputVC.tableView.alpha = 0.25f;
            } dismissCallback:^{
                inputVC.tableView.alpha = 1.0f;
            }];
            [[(IMInputBaseViewController *)self.viewControllers[0] view] addSubview:hintView];
            [hintView present];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenAddDragUIHint];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    [self layoutViewControllers];
    [self updateNavigationBar];
    [self performSelector:@selector(activateTargetViewController) withObject:nil afterDelay:0];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove any customisation on the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(isBeingPopped)
    {
        self.scrollView = nil;
        for(IMInputBaseViewController *vc in [self.viewControllers copy])
        {
            [self removeVC:vc];
        }
        self.viewControllers = nil;
    }
}

#pragma mark - Logic
- (void)reloadViewData:(NSNotification *)note
{
    [super reloadViewData:note];
    
    NSDictionary *userInfo = [note userInfo];
    if(userInfo && userInfo[NSDeletedObjectsKey])
    {
        for(NSManagedObjectID *objectID in userInfo[NSDeletedObjectsKey])
        {
            for(IMInputBaseViewController *vc in self.viewControllers)
            {
                if(vc.eventOID && [objectID isEqual:vc.eventOID])
                {
                    [self handleBack:self withSound:NO];
                    return;
                }
            }
        }
    }
}
- (void)saveEvent:(id)sender
{
    IMInputBaseViewController *targetVC = [self targetViewController];
    [targetVC.view endEditing:YES];
    
    NSManagedObjectContext *moc = [[IMCoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSError *validationError = nil;
        NSInteger vcIndex = 0;
        for(IMInputBaseViewController *vc in self.viewControllers)
        {
            validationError = [vc validationError];
            if(validationError)
            {
                [self.scrollView scrollRectToVisible:CGRectMake(vcIndex*self.scrollView.bounds.size.width, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:validationError.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
                
                break;
            }
            vcIndex ++;
        }
        
        if(!validationError)
        {
            NSMutableArray *newEvents = [NSMutableArray array];
            
            NSError *saveError = nil;
            for(IMInputBaseViewController *vc in self.viewControllers)
            {
                IMEvent *event = [vc saveEvent:&saveError];
                if(event && !saveError)
                {
                    [newEvents addObject:event];
                }
            }
            
            // If we're editing an event, remove it so that we don't continually create new reminders
            if(self.event)
            {
                [newEvents removeObject:self.event];
            }
            
            // Iterate over our newly created events and see if any match our rules
            NSArray *rules = [[IMReminderController sharedInstance] fetchAllReminderRules];
            if(rules && [rules count])
            {
                for(IMReminderRule *rule in rules)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:rule.predicate];
                    if(predicate)
                    {
                        NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:[newEvents filteredArrayUsingPredicate:predicate]];
                    
                        // If we have a match go ahead and create a reminder
                        if(filteredEvents && [filteredEvents count])
                        {
                            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMReminder" inManagedObjectContext:moc];
                            IMReminder *newReminder = (IMReminder *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                            newReminder.created = [NSDate date];
                            
                            NSDate *triggerDate = [[filteredEvents objectAtIndex:0] valueForKey:@"timestamp"];
                            
                            newReminder.message = rule.name;
                            if([rule.intervalType integerValue] == kMinuteIntervalType)
                            {
                                newReminder.date = [triggerDate dateByAddingMinutes:[rule.intervalAmount integerValue]];
                            } 
                            else if([rule.intervalType integerValue] == kHourIntervalType)
                            {
                                newReminder.date = [triggerDate dateByAddingHours:[rule.intervalAmount integerValue]];
                            }
                            else if([rule.intervalType integerValue] == kDayIntervalType)
                            {
                                newReminder.date = [triggerDate dateByAddingDays:[rule.intervalAmount integerValue]];
                            }
                            newReminder.type = [NSNumber numberWithInteger:kReminderTypeDate];
                            
                            NSError *error = nil;                        
                            [moc save:&error];
                            
                            if(!error)
                            {
                                [[IMReminderController sharedInstance] setNotificationsForReminder:newReminder];
                                
                                // Notify anyone interested that we've updated our reminders
                                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                            }
                        }
                    }
                }
            }
            
            [self handleBack:self withSound:NO];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"We're unable to save your data as a sync is in progress!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)deleteEvent:(id)sender
{
    
    IMInputBaseViewController *targetVC = [self targetViewController];
    [targetVC triggerDeleteEvent:sender];
}
- (void)discardChanges:(id)sender
{
    for(IMInputBaseViewController *vc in self.viewControllers)
    {
        [vc discardChanges];
    }
    
    [self handleBack:self];
}
- (void)addVC:(UIViewController *)vc
{
    if(vc)
    {
        CGFloat contentWidth = self.scrollView.contentSize.width;
        vc.view.frame = CGRectMake(contentWidth, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        
        [vc willMoveToParentViewController:vc];
        [self.scrollView addSubview:vc.view];
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        
        [self.viewControllers addObject:vc];
        [self layoutViewControllers];
        [self updateNavigationBar];
    }
}
- (void)removeVC:(UIViewController *)vc
{
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    [vc didMoveToParentViewController:nil];
    
    [self.viewControllers removeObject:vc];
    [self layoutViewControllers];
    [self activateTargetViewController];
    [self updateNavigationBar];
}
- (void)layoutViewControllers
{
    if([self.viewControllers count])
    {
        CGFloat x = 0.0f;
        for(IMInputBaseViewController *vc in self.viewControllers)
        {
            vc.view.frame = CGRectMake(x, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            x += self.scrollView.bounds.size.width;
        }
        
        self.scrollView.contentSize = CGSizeMake(x, self.scrollView.bounds.size.height);
    }
}
- (void)activateTargetViewController
{
    IMInputBaseViewController *targetVC = [self targetViewController];
    if(targetVC)
    {
        for(IMInputBaseViewController *vc in self.viewControllers)
        {
            if([vc activeView])
            {
                [vc willBecomeInactive];
            }
        }
        [targetVC didBecomeActive];
        
        [self updateNavigationBar];
        [targetVC updateUI];
    }
}
- (void)handleBack:(id)sender
{
    isBeingPopped = YES;
    
    [super handleBack:sender];
}
- (void)handleBack:(id)sender withSound:(BOOL)playSound
{
    isBeingPopped = YES;
    
    [super handleBack:sender withSound:playSound];
}

#pragma mark - UI
- (void)presentAddReminder:(id)sender
{
    UIActionSheet *actionSheet = nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remind me in", nil)
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                destructiveButtonTitle:nil
                                     otherButtonTitles:NSLocalizedString(@"15 minutes", nil), NSLocalizedString(@"30 minutes", nil), NSLocalizedString(@"1 hour", nil), NSLocalizedString(@"2 hours", nil), NSLocalizedString(@"The future", @"An option allow users to be reminded at some point in the future"), nil];
    actionSheet.tag = kExistingImageActionSheetTag;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)presentMediaOptions:(id)sender
{
    IMInputBaseViewController *targetVC = [self targetViewController];
    UIActionSheet *actionSheet = nil;
    if(targetVC.currentPhotoPath)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:targetVC
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Remove photo", nil)
                                         otherButtonTitles:NSLocalizedString(@"View photo", nil), nil];
        actionSheet.tag = kExistingImageActionSheetTag;
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:targetVC
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
        actionSheet.tag = kImageActionSheetTag;
    }
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)presentGeotagOptions:(id)sender
{
    IMInputBaseViewController *targetVC = [self targetViewController];
    if((self.event && [self.event.latitude doubleValue] != 0.0 && [self.event.longitude doubleValue] != 0.0) || ([targetVC.lat doubleValue] != 0.0 && [targetVC.lon doubleValue] != 0.0))
    {
        UIActionSheet *actionSheet = nil;
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:targetVC
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Remove", nil)
                                         otherButtonTitles:NSLocalizedString(@"View on map", nil), NSLocalizedString(@"Update location", nil), nil];
        actionSheet.tag = kGeotagActionSheetTag;
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Location", nil)
                                                            message:NSLocalizedString(@"Are you sure you'd like to add location data to this event?" ,nil)
                                                           delegate:targetVC
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Add", nil), nil];
        alertView.tag = kGeoTagAlertViewTag;
        [alertView show];
    }
}
- (void)updateNavigationBar
{
    [self setNeedsStatusBarAppearanceUpdate];
    
    IMInputBaseViewController *targetVC = [self targetViewController];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:[[self targetViewController] navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"trans"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[IMFont standardDemiBoldFontWithSize:17.0f]}];
    
    if([self.viewControllers count] > 1)
    {
        NSInteger page = (NSInteger)floorf(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
        IMNavPaginationTitleView *titleView = [[IMNavPaginationTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        [titleView setTitle:targetVC.title];
        [titleView.pageControl setViewControllers:self.viewControllers];
        [titleView.pageControl setCurrentPage:page];
        self.navigationItem.titleView = titleView;
    }
    else
    {
        self.navigationItem.title = targetVC.title;
        self.navigationItem.titleView = nil;
    }
}

#pragma mark - UIPopoverController logic
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self closeActivePopoverController];
}
- (void)popoverController:(UIPopoverController *)popoverController
willRepositionPopoverToRect:(inout CGRect *)rect
                   inView:(inout UIView *__autoreleasing *)view
{
    IMInputBaseViewController *targetVC = self.targetViewController;
    if(targetVC && targetVC.keyboardShortcutAccessoryView)
    {
        UIView *button = [self.targetViewController.keyboardShortcutAccessoryView photoButton];
        *rect = [self.view convertRect:CGRectMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds), 1.0f, 1.0f) fromView:button];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    isAddingQuickEntry = NO;
    isAnimatingAddEntry = NO;
    originalContentOffset = aScrollView.contentOffset;
    
    // Lazily create our add entry image view
    if(!addEntryBubbleImageView)
    {
        addEntryBubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddEntryMedicineBubble"]];
        addEntryBubbleImageView.alpha = 0.0f;
        [self.view addSubview:addEntryBubbleImageView];
    }
    
    addEntryBubbleImageView.frame = CGRectMake(self.view.frame.size.width - addEntryBubbleImageView.frame.size.width, self.scrollView.frame.size.height/2.0f - addEntryBubbleImageView.frame.size.height/2.0f, addEntryBubbleImageView.frame.size.width, addEntryBubbleImageView.frame.size.height);
}
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if(offsetX < 0.0f) offsetX = 0.0f;
    if(offsetX > self.scrollView.contentSize.width) offsetX = self.scrollView.contentSize.width;
    self.currentIndex = (NSUInteger)floorf(offsetX / self.scrollView.bounds.size.width);
    
    CGFloat dragOffsetX = [self.viewControllers count] > 1 ? aScrollView.contentOffset.x - ([self.viewControllers count]-1)*aScrollView.bounds.size.width : aScrollView.contentOffset.x;
    if(aScrollView.isTracking && dragOffsetX > kDragBuffer && [self.viewControllers count] < 8)
    {
        addEntryBubbleImageView.alpha = 1.0f; //((offsetX-kDragBuffer > 20.0f ? 20.0f : offsetX-kDragBuffer)/20.0f)*1.0f;
        aScrollView.alpha = 1.0f - ((dragOffsetX-kDragBuffer > 20.0f ? 20.0f : dragOffsetX-kDragBuffer)/20.0f)*0.5f;
        
        if(dragOffsetX-kDragBuffer < 20.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryMedicineBubble"];
        }
        else if(dragOffsetX-kDragBuffer < 40.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryBloodBubble"];
        }
        else if(dragOffsetX-kDragBuffer < 60.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryMealBubble"];
        }
        else if(dragOffsetX-kDragBuffer < 80.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryActivityBubble"];
        }
        else if(dragOffsetX-kDragBuffer < 100.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryNoteBubble"];
        }
    }
    else
    {
        addEntryBubbleImageView.alpha = 0.0f;
        aScrollView.alpha = 1.0f;
    }
    
    if(isAddingQuickEntry && !aScrollView.tracking && !isAnimatingAddEntry)
    {
        [aScrollView scrollRectToVisible:CGRectMake(aScrollView.contentSize.width-aScrollView.frame.size.width, 0.0f, aScrollView.frame.size.width, aScrollView.frame.size.height) animated:YES];
        isAnimatingAddEntry = YES;
    }
    else if(!aScrollView.isTracking && aScrollView.contentOffset.x > aScrollView.contentSize.width-aScrollView.frame.size.width && !isAnimatingAddEntry)
    {
        [aScrollView scrollRectToVisible:CGRectMake(aScrollView.contentSize.width-aScrollView.frame.size.width, 0.0f, aScrollView.frame.size.width, aScrollView.frame.size.height) animated:YES];
        isAnimatingAddEntry = YES;
    }
    
    if(aScrollView.isTracking)
    {
        scrollVelocity = [[aScrollView panGestureRecognizer] velocityInView:aScrollView.superview];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetX = [self.viewControllers count] > 1 ? aScrollView.contentOffset.x - ([self.viewControllers count]-1)*aScrollView.frame.size.width : aScrollView.contentOffset.x;
    if(fabsf(scrollVelocity.x) < 150.0f && offsetX > kDragBuffer && [self.viewControllers count] < 8)
    {
        isAddingQuickEntry = YES;
        
        if(offsetX-kDragBuffer < 20.0f)
        {
            IMMedicineInputViewController *vc = [[IMMedicineInputViewController alloc] init];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 40.0f)
        {
            IMBGInputViewController *vc = [[IMBGInputViewController alloc] init];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 60.0f)
        {
            IMMealInputViewController *vc = [[IMMealInputViewController alloc] init];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 80.0f)
        {
            IMActivityInputViewController *vc = [[IMActivityInputViewController alloc] init];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 100.0f)
        {
            IMNoteInputViewController *vc = [[IMNoteInputViewController alloc] init];
            [self addVC:(UIViewController *)vc];
        }
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    isAnimatingAddEntry = NO;
    isAddingQuickEntry = NO;
    [self activateTargetViewController];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    if(!isAddingQuickEntry && !isAnimatingAddEntry)
    {
        [self activateTargetViewController];
    }
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex > 3) return;
    
    NSInteger minutes = 0;
    switch(buttonIndex)
    {
        case 0:
            minutes = 15;
            break;
        case 1:
            minutes = 30;
            break;
        case 2:
            minutes = 60;
            break;
        case 3:
            minutes = 120;
            break;
    }
    
    NSDate *date = [[NSDate date] dateByAddingMinutes:minutes];
    IMTimeReminderViewController *vc = [[IMTimeReminderViewController alloc] initWithDate:date];
    IMNavigationController *nvc = [[IMNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Keyboard handling
- (void)keyboardWillBeShown:(NSNotification *)aNotification
{
    [UIView animateWithDuration:[self keyboardAnimationDurationForNotification:aNotification] animations:^{
        CGRect keyboardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGSize kbSize = [self.view convertRect:keyboardFrame fromView:nil].size;
        
        self.scrollView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length - kbSize.height);
        [self layoutViewControllers];
    } completion:nil];
}
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification:aNotification] animations:^{
        CGRect keyboardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGSize kbSize = [self.view convertRect:keyboardFrame fromView:nil].size;
        
        self.scrollView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length- kbSize.height);
        [self layoutViewControllers];
    } completion:nil];
}
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification:aNotification] animations:^{
        self.scrollView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length);
        [self layoutViewControllers];
    } completion:nil];
}

#pragma mark - Helpers
- (IMInputBaseViewController *)targetViewController
{
    if(self.viewControllers && [self.viewControllers count])
    {
        NSUInteger index = self.currentIndex;
        if(index > [self.viewControllers count]-1) index = [self.viewControllers count]-1;
        return (IMInputBaseViewController *)self.viewControllers[index];
    }
    
    return nil;
}

#pragma mark - Rotation handling methods
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.prerotationIndex = self.currentIndex;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutViewControllers];
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width*self.prerotationIndex, 0.0f);
}

#pragma mark - Autorotation
- (void)orientationChanged:(NSNotification *)note
{
    UIDeviceOrientation appOrientation = [[UIDevice currentDevice] orientation];
    
    if(UIInterfaceOrientationIsLandscape(appOrientation))
    {
        IMInputBaseViewController *vc = [self targetViewController];
        if(vc)
        {
           // [vc presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    }
}

#pragma mark - UIViewController methods
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
