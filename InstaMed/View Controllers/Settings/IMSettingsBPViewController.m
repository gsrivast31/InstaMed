//
//  IMSettingsBPViewController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 25/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsBPViewController.h"

@interface IMSettingsBPViewController ()

@end

@implementation IMSettingsBPViewController

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Blood Pressure", nil);
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Logic
- (void)minSliderValueChanged:(UISlider *)sender {
    NSNumber *value = [NSNumber numberWithUnsignedInt:sender.value];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kMinHealthyBPKey];
}

- (void)maxSliderValueChanged:(UISlider *)sender {
    NSNumber *value = [NSNumber numberWithUnsignedInt:sender.value];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kMaxHealthyBPKey];
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
        cell.textLabel.text = NSLocalizedString(@"Min healthy", @"An option label for determining the lowest a blood pressure reading can be before being considered unhealthy");
        
        IMSlider *slider = [[IMSlider alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        slider.minimumValue = 10;
        slider.maximumValue = 300;
        
        NSNumber *minValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyBPKey];
        slider.value = [minValue floatValue];
        cell.accessoryView = slider;
        
        [slider addTarget:self action:@selector(minSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    } else if(indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Max healthy", @"An option label for determining the highest a blood pressure reading can be before being considered unhealthy");
        
        IMSlider *slider = [[IMSlider alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        slider.minimumValue = 10;
        slider.maximumValue = 300;
        
        NSNumber *maxValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyBPKey];
        slider.value = [maxValue floatValue];
        cell.accessoryView = slider;
        
        [slider addTarget:self action:@selector(maxSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
