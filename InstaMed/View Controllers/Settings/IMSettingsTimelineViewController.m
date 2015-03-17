//
//  IMSettingsTimelineViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsTimelineViewController.h"

@interface IMSettingsTimelineViewController ()

// UI
- (void)toggleSearchResultCollapse:(UISwitch *)sender;

@end

@implementation IMSettingsTimelineViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Timeline", nil);
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UI
- (void)toggleSearchResultCollapse:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kFilterSearchResultsKey];
}
- (void)toggleInlineImages:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kShowInlineImages];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMSettingCell"];
    if (cell == nil)
    {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMSettingCell"];
    }
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"Collapse search results", @"A setting asking whether or not results should be collapsed when searching occurs");

        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl addTarget:self action:@selector(toggleSearchResultCollapse:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;

        [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kFilterSearchResultsKey]];
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Show inline images", @"A setting asking whether or not to display inline images");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl addTarget:self action:@selector(toggleInlineImages:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
        
        [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kShowInlineImages]];
    }

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
