//
//  IMSideMenuViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 27/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMAppDelegate.h"
#import "IMReminderController.h"
#import "IMMediaController.h"

#import "IMSideMenuViewController.h"
#import "IMSettingsViewController.h"
#import "IMRemindersViewController.h"
#import "IMJournalViewController.h"
#import "IMExportViewController.h"
#import "IMTagsViewController.h"
#import "IMUsersListViewController.h"
#import "IMReportTableViewController.h"
#import "IMDayRecordTableViewController.h"

#import "IMAnalyticsDateTableViewController.h"

#import "IMSideMenuCell.h"
#import "IMUser.h"

@interface IMSideMenuViewController ()
{
    id reminderUpdateNotifier;
}

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* label;
@end

@implementation IMSideMenuViewController

@synthesize label;
@synthesize imageView;

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 205.0f)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"icn_male"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileName];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UILabel* changeUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 178, 0, 18)];
        changeUserLabel.text = @"Change User";
        changeUserLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        changeUserLabel.backgroundColor = [UIColor clearColor];
        changeUserLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        changeUserLabel.userInteractionEnabled = YES;
        [changeUserLabel sizeToFit];
        changeUserLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUser:)];
        [changeUserLabel addGestureRecognizer:tapGesture];
        
        [view addSubview:imageView];
        [view addSubview:label];
        [view addSubview:changeUserLabel];
        view;
    });
    
    self.tableView.opaque = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor clearColor];

    reminderUpdateNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kRemindersUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshName:) name:kCurrentProfileChangedNotification object:nil];
    [self setDefaultProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:reminderUpdateNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCurrentProfileChangedNotification object:nil];
}

- (void)changeUser:(UIGestureRecognizer*)recognizer {
    IMAppDelegate *appDelegate = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = (UINavigationController *)[(REFrostedViewController *)appDelegate.viewController contentViewController];;
    [(REFrostedViewController *)appDelegate.viewController hideMenuViewController];

    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    IMUsersListViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"userListController"];
    [navigationController pushViewController:vc animated:NO];
}

- (void)setDefaultProfile {
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] newPrivateContext];
    if(moc) {
        [moc performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMUser" inManagedObjectContext:moc];
            [request setEntity:entity];
            [request setResultType:NSManagedObjectResultType];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid == %@", [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey]];
            [request setPredicate:predicate];
            
            // Execute the fetch.
            NSError *error = nil;
            NSArray *objects = [moc executeFetchRequest:request error:&error];
            if (objects != nil && [objects count] > 0) {
                IMUser* user = [objects objectAtIndex:0];
                imageView.image = [UIImage imageWithData:user.profilePhoto];
            }
        }];
     }
}

- (void)refreshName:(NSNotification*)notification {
    NSDictionary* info = notification.userInfo;
    NSString* name = [info valueForKey:@"name"];
    UIImage* image = [info valueForKey:@"image"];

    label.text = name;
    imageView.image = image;
}

#pragma mark - UITableViewDataSource methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Menu", @"The section header for generic menu items");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"IMSideMenuCell";
    
    IMSideMenuCell *cell = (IMSideMenuCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[IMSideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMSideMenuCell"];
    }
    
    cell.tintColor = nil;
    cell.detailTextLabel.text = nil;
    if(indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Journal", nil);
        cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconJournal"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconJournalHighlighted"];
    } else if(indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Reports", nil);
        cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconJournal"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconJournalHighlighted"];
    } else if(indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Reminders", nil);
        cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconReminders"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconRemindersHighlighted"];
    } else if(indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Analytics", nil);
        cell.accessoryIcon.image = [UIImage imageNamed:@"JournalIconDeviation"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"JournalIconDeviation"];
    } else if(indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"Tags", nil);
        cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconTags"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconTagsHighlighted"];
    } else if(indexPath.row == 5) {
        cell.textLabel.text = NSLocalizedString(@"Profiles", nil);
        cell.accessoryIcon.image = [UIImage imageNamed:@"icn_male"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"icn_male"];
    } else if(indexPath.row == 6) {
        cell.textLabel.text = NSLocalizedString(@"Export", @"Menu item to take users to the export screen");
        cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconExport"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconExportHighlighted"];
    } else if(indexPath.row == 7) {
        cell.textLabel.text = NSLocalizedString(@"Settings", nil);
        cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconSettings"];
        cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconSettingsHighlighted"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    IMAppDelegate *appDelegate = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = nil;
    BOOL animateViewControllerChange = NO;
    
    navigationController = (UINavigationController *)[(REFrostedViewController *)appDelegate.viewController contentViewController];
    [(REFrostedViewController *)appDelegate.viewController hideMenuViewController];

    if(indexPath.row == 0) {
        [navigationController popToRootViewControllerAnimated:animateViewControllerChange];
    } else if(indexPath.row == 1) {
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        IMReportTableViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"reportTableViewController"];
        [navigationController pushViewController:vc animated:animateViewControllerChange];
    } else if(indexPath.row == 2) {
        if(![[navigationController topViewController] isKindOfClass:[IMRemindersViewController class]]) {
            IMRemindersViewController *vc = [[IMRemindersViewController alloc] init];
            [navigationController pushViewController:vc animated:animateViewControllerChange];
        }
    } else if(indexPath.row == 3) {
        //Analytics
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        IMReportTableViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"analyticDateTableController"];
        [navigationController pushViewController:vc animated:animateViewControllerChange];
    } else if(indexPath.row == 4) {
        if(![[navigationController topViewController] isKindOfClass:[IMTagsViewController class]]) {
            IMTagsViewController *vc = [[IMTagsViewController alloc] init];
            [navigationController pushViewController:vc animated:animateViewControllerChange];
        }
    } else if(indexPath.row == 5) {
        if(![[navigationController topViewController] isKindOfClass:[IMUsersListViewController class]]) {
            UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            IMUsersListViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"userListController"];
            [navigationController pushViewController:vc animated:animateViewControllerChange];
        }
    } else if(indexPath.row == 6) {
        if(![[navigationController topViewController] isKindOfClass:[IMExportViewController class]]) {
            IMExportViewController *vc = [[IMExportViewController alloc] init];
            [navigationController pushViewController:vc animated:animateViewControllerChange];
        }
    } else if(indexPath.row == 7) {
        if(![[navigationController topViewController] isKindOfClass:[IMSettingsViewController class]]) {
            IMSettingsViewController *vc = [[IMSettingsViewController alloc] init];
            [navigationController pushViewController:vc animated:animateViewControllerChange];
        }
    }
}

@end
