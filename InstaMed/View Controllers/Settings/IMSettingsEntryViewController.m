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
- (void)toggleAutoGeotagging:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kAutomaticallyGeotagEvents];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
