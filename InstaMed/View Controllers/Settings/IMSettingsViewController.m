//
//  IMSettingsViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 17/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UAAppReviewManager/UAAppReviewManager.h>
#import "IMAppDelegate.h"

#import "IMSettingsViewController.h"
#import "IMSettingsEntryViewController.h"
#import "IMSettingsGlucoseViewController.h"
#import "IMSettingsCholesterolViewController.h"
#import "IMSettingsBPViewController.h"
#import "IMSettingsWeightViewController.h"
#import "IMSettingsTimelineViewController.h"
#import "IMSettingsDropboxViewController.h"
#import "IMSettingsLicensesViewController.h"

#import "IMSettingsViewCell.h"
#import "IMHelper.h"
#import "IMBGReading.h"

@interface IMSettingsViewController ()

@end

@implementation IMSettingsViewController

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings title");
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsChangedNotification object:nil];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 6;
    } else if(section == 1) {
        return 3;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(@"General", @"General settings section title");
    } else if(section == 1) {
        return NSLocalizedString(@"Other", @"Settings section for miscellaneous information");
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    IMGenericTableHeaderView *header = [[IMGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMSettingsViewCell *cell = (IMSettingsViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMSettingCell"];
    if (cell == nil) {
        cell = [[IMSettingsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMSettingCell"];
    }
    
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Timeline settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Entry settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Glucose settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Cholesterol settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Blood Pressure settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Weight settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Need help? Contact support!", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ 😊", NSLocalizedString(@"Rate InstaMed in the App Store", nil)];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Licenses", @"An option to view third-party software licenses used throughout the application");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            IMSettingsTimelineViewController *vc = [[IMSettingsTimelineViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } if(indexPath.row == 1) {
            IMSettingsEntryViewController *vc = [[IMSettingsEntryViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 2) {
            IMSettingsGlucoseViewController *vc = [[IMSettingsGlucoseViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 3) {
            IMSettingsCholesterolViewController *vc = [[IMSettingsCholesterolViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 4) {
            IMSettingsBPViewController *vc = [[IMSettingsBPViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 5) {
            IMSettingsWeightViewController *vc = [[IMSettingsWeightViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if(indexPath.section == 1) {
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if(indexPath.row == 0) {
            if([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
                [mailController setMailComposeDelegate:self];
                [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
                [mailController setSubject:@"InstaMed Support"];
                [mailController setToRecipients:@[@"gaurav.sri87@gmail.com"]];
                [mailController setMessageBody:[NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"I need help with InstaMed! Here's the problem:", @"A default message shown to users when contacting support for help")] isHTML:NO];
                if(mailController) {
                    [self presentViewController:mailController animated:YES completion:nil];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:NSLocalizedString(@"This device hasn't been setup to send emails.", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        } else if(indexPath.row == 1) {
            [UAAppReviewManager rateApp];
        } else if(indexPath.row == 2) {
            IMSettingsLicensesViewController *vc = [[IMSettingsLicensesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        if(indexPath.row >= 0 && indexPath.row <= 5) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - MFMailComposeViewDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Support email sent", nil)
                                                            message:NSLocalizedString(@"We've received your support request and will try to reply as soon as possible", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
