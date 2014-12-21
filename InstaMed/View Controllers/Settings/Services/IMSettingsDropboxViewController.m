//
//  IMSettingsDropboxViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 31/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Dropbox/Dropbox.h>
#import "IMAppDelegate.h"
#import "IMSettingsDropboxViewController.h"

@interface IMSettingsDropboxViewController ()
{
    id linkNotifier;
}
@end

@implementation IMSettingsDropboxViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Dropbox Settings", nil);
        
        __weak typeof(self) weakSelf = self;
        linkNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kDropboxLinkNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:linkNotifier];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Dropbox", nil);
    }
    
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
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMSettingCell"];
    if (cell == nil)
    {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMSettingCell"];
    }
    
    if(indexPath.section == 0)
    {
        if(![[DBAccountManager sharedManager] linkedAccount])
        {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Link with Dropbox", nil);
            }
        }
        else
        {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Unlink Dropbox account", nil);
            }
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }

    return cell;
}

#pragma mar - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0)
    {
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        if(!account)
        {
            if(indexPath.row == 0)
            {
                [[DBAccountManager sharedManager] linkFromController:self];
            }
        }
        else
        {
            if(indexPath.row == 0)
            {
                [account unlink];
                [aTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}
@end
