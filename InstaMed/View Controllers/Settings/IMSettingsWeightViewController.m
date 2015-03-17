//
//  IMSettingsWeightViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 25/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsWeightViewController.h"

@interface IMSettingsWeightViewController ()

@end

@implementation IMSettingsWeightViewController

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Weight", nil);
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Logic
- (void)sliderValueChanged:(UISlider *)sender {
    NSNumber *value = [NSNumber numberWithUnsignedInt:sender.value];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kTargetWeightKey];
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
        cell.textLabel.text = NSLocalizedString(@"Target Weight", @"An option label for setting target weight");
        
        IMSlider *slider = [[IMSlider alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        slider.minimumValue = 0;
        slider.maximumValue = 200;
        
        NSNumber *value = [[NSUserDefaults standardUserDefaults] valueForKey:kTargetWeightKey];
        slider.value = [value floatValue];
        cell.accessoryView = slider;
        
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
