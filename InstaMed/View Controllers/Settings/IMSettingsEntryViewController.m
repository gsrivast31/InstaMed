//
//  IMSettingsEntryViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsEntryViewController.h"

@interface IMSettingsEntryViewController ()

// UI
- (void)toggleSmartInput:(UISwitch *)sender;
- (void)toggleAutoGeotagging:(UISwitch *)sender;

@end

@implementation IMSettingsEntryViewController

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Entry", nil);
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UI
- (void)toggleSmartInput:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kUseSmartInputKey];
}

- (void)toggleAutoGeotagging:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kAutomaticallyGeotagEvents];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMSettingCell"];
    if (cell == nil) {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMSettingCell"];
    }
    
    if(indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Smart input", @"A settings switch to control the Smart Input feature");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl addTarget:self action:@selector(toggleSmartInput:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
        
        [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUseSmartInputKey]];
    } else if(indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Auto-geotag events", @"A setting asking whether or not to automatically geotag events");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl addTarget:self action:@selector(toggleAutoGeotagging:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
        
        [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallyGeotagEvents]];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
