//
//  IMRemindersViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMRemindersViewController.h"
#import "IMRemindersTooltipView.h"

@interface IMRemindersViewController ()
{
    id reminderUpdateNotifier;
}
@property (nonatomic, strong) IMViewControllerMessageView *noRemindersMessageView;
@property (nonatomic, strong) NSArray *reminders;
@property (nonatomic, strong) NSArray *rules;

@end

@implementation IMRemindersViewController
@synthesize reminders = _reminders;
@synthesize rules = _rules;

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Reminders", nil);
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconAdd.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(addReminder:)];
    [self.navigationItem setRightBarButtonItem:addBarButtonItem animated:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadViewData:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    reminderUpdateNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kRemindersUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf reloadViewData:note];
    }];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenReminderTooltip])
    {
        [self showTips];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:reminderUpdateNotifier];
}

#pragma mark - Logic
- (void)reloadViewData:(NSNotification *)note
{
    [super reloadViewData:note];
    
    _rules = [[IMReminderController sharedInstance] fetchAllReminderRules];
    _reminders = [[IMReminderController sharedInstance] fetchAllReminders];
    
    [self updateView];
}
- (void)updateView
{
    if(!self.noRemindersMessageView)
    {
        // No entry label
        self.noRemindersMessageView = [IMViewControllerMessageView addToViewController:self
                                                                             withTitle:NSLocalizedString(@"No Reminders", nil)
                                                                            andMessage:NSLocalizedString(@"You currently don't have any reminders setup. To add one, tap the + icon.", nil)];
        [self.noRemindersMessageView setHidden:YES];
    }
 
    if((_reminders && [_reminders count]) || (_rules && [_rules count]))
    {
        [self.noRemindersMessageView setHidden:YES];
    }
    else
    {
        [self.noRemindersMessageView setHidden:NO];
    }
    
    [self.tableView setEditing:NO];
    [self.tableView reloadData];
}
- (void)addReminder:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Date reminder", nil), NSLocalizedString(@"Location reminder", nil), NSLocalizedString(@"Rule-based reminder", nil), nil];
    [actionSheet showInView:self.view];
}
- (void)showTips
{
    IMAppDelegate *appDelegate = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *targetVC = appDelegate.viewController;
    
    IMTooltipViewController *modalView = [[IMTooltipViewController alloc] initWithParentVC:targetVC andDelegate:self];
    IMRemindersTooltipView *tooltipView = [[IMRemindersTooltipView alloc] initWithFrame:CGRectZero];
    [modalView setContentView:tooltipView];
    [modalView present];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    NSInteger sections = 0;
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeRepeating] count]) sections ++;
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeDate] count]) sections ++;
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeLocation] count]) sections ++;
    if(_rules && [_rules count]) sections ++;
    
    return sections;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger adjustedSection = [self adjustedSectionForSection:section];
    if(adjustedSection == kReminderTypeRule)
    {
        if(!_rules) return 0;
        return [_rules count];
    }
    else
    {
        if(!_reminders) return 0;
        return [[_reminders objectAtIndex:adjustedSection] count];
    }
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger adjustedSection = [self adjustedSectionForSection:section];
    if(adjustedSection == kReminderTypeRepeating) return NSLocalizedString(@"Repeating reminders", nil);
    if(adjustedSection == kReminderTypeDate) return NSLocalizedString(@"One-time reminders", nil);
    if(adjustedSection == kReminderTypeLocation) return NSLocalizedString(@"Location-based reminders", nil);
    if(adjustedSection == kReminderTypeRule) return NSLocalizedString(@"Rule-based reminders", nil);
    
    return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    IMGenericTableHeaderView *header = [[IMGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMReminderCell"];
    if (cell == nil)
    {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMReminderCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSInteger adjustedSection = [self adjustedSectionForSection:indexPath.section];
    if(adjustedSection == kReminderTypeDate)
    {
        IMReminder *reminder = (IMReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        cell.textLabel.text = reminder.message;
        cell.detailTextLabel.text = [[IMReminderController sharedInstance] detailForReminder:reminder];
    }
    else if(adjustedSection == kReminderTypeRepeating)
    {
        IMReminder *reminder = (IMReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        cell.textLabel.text = reminder.message;
        cell.detailTextLabel.text = [[IMReminderController sharedInstance] detailForReminder:reminder];
    }
    else if(adjustedSection == kReminderTypeLocation)
    {
        IMReminder *reminder = (IMReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        cell.textLabel.text = reminder.message;
        cell.detailTextLabel.text = [[IMReminderController sharedInstance] detailForReminder:reminder];
    }
    else if(adjustedSection == kReminderTypeRule)
    {
        IMReminderRule *rule = (IMReminderRule *)[_rules objectAtIndex:indexPath.row];
        cell.textLabel.text = rule.name;
        cell.detailTextLabel.text = nil;
    }
    
    switch(adjustedSection)
    {
        case kReminderTypeDate:
            cell.imageView.image = [UIImage imageNamed:@"ListMenuIconTimeReminder"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"ListMenuIconTimeReminderHighlighted"];
            break;
        case kReminderTypeRepeating:
            cell.imageView.image = [UIImage imageNamed:@"ListMenuIconDateReminder"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"ListMenuIconDateReminderHighlighted"];
            break;
        case kReminderTypeLocation:
            cell.imageView.image = [UIImage imageNamed:@"ListMenuIconLocationReminder"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"ListMenuIconLocationReminderHighlighted"];
            break;
        case kReminderTypeRule:
            cell.imageView.image = [UIImage imageNamed:@"ListMenuIconRuleReminder"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"ListMenuIconRuleReminderHighlighted"];
            break;
        default:
            cell.imageView.image = nil;
            cell.imageView.highlightedImage = nil;
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    NSInteger adjustedSection = [self adjustedSectionForSection:indexPath.section];
    if(adjustedSection == kReminderTypeRule)
    {
        IMReminderRule *rule = (IMReminderRule *)[_rules objectAtIndex:indexPath.row];
        
        IMRuleReminderViewController *vc = [[IMRuleReminderViewController alloc] initWithReminderRule:rule];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(adjustedSection == kReminderTypeDate || adjustedSection == kReminderTypeRepeating)
    {
        IMReminder *reminder = (IMReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        
        IMTimeReminderViewController *vc = [[IMTimeReminderViewController alloc] initWithReminder:reminder];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        IMReminder *reminder = (IMReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];

        IMLocationReminderViewController *vc = [[IMLocationReminderViewController alloc] initWithReminder:reminder];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSInteger adjustedSection = [self adjustedSectionForSection:indexPath.section];
        
        NSError *error = nil;
        if(adjustedSection == kReminderTypeRule)
        {
            IMReminderRule *rule = (IMReminderRule *)[_rules objectAtIndex:indexPath.row];
            [[IMReminderController sharedInstance] deleteReminderRule:rule error:&error];
        }
        else
        {
            IMReminder *reminder = (IMReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
            [[IMReminderController sharedInstance] deleteReminderWithID:reminder.guid error:&error];
        }
        
        if(!error)
        {
            [self updateView];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:NSLocalizedString(@"We were unable to delete your reminder rule for the following reason: %@", [error localizedDescription])
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        IMTimeReminderViewController *vc = [[IMTimeReminderViewController alloc] init];
        IMNavigationController *nvc = [[IMNavigationController alloc] initWithRootViewController:vc];
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
    }
    else if(buttonIndex == 1)
    {
        IMLocationReminderViewController *vc = [[IMLocationReminderViewController alloc] init];
        IMNavigationController *nvc = [[IMNavigationController alloc] initWithRootViewController:vc];
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
    }
    else if(buttonIndex == 2)
    {
        IMRuleReminderViewController *vc = [[IMRuleReminderViewController alloc] init];
        IMNavigationController *nvc = [[IMNavigationController alloc] initWithRootViewController:vc];
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
    }
}

#pragma mark - IMTooltipViewControllerDelegate methods
- (void)willDisplayModalView:(IMTooltipViewController *)aModalController
{
    // STUB
}
- (void)didDismissModalView:(IMTooltipViewController *)aModalController
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenReminderTooltip];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Helpers
- (NSInteger)adjustedSectionForSection:(NSInteger)section
{
    NSMutableArray *sections = [NSMutableArray array];
    
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeRepeating] count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeRepeating]];
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeLocation] count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeLocation]];
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeDate] count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeDate]];
    if(_rules && [_rules count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeRule]];
    
    if([sections count])
    {
        return [[sections objectAtIndex:section] integerValue];
    }
    
    return 0;
}
@end
