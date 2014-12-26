//
//  IMSettingsCholesterolViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 25/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsCholesterolViewController.h"

@interface IMSettingsCholesterolViewController ()

@end

@implementation IMSettingsCholesterolViewController

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Cholesterol", nil);
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Logic
- (void)changeCholesterolUnits:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex] forKey:kChTrackingUnitKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)minSliderValueChanged:(UISlider *)sender {
    NSInteger userUnit = [IMHelper userChUnit];
    if(userUnit == ChTrackingUnitMG) {
        sender.value = roundf(sender.value);
    } else {
        sender.value = round(sender.value*2.0f)/2.0f;
    }
    
    NSNumber *transformedValue = [IMHelper convertCholesterolValue:[NSNumber numberWithFloat:sender.value] fromUnit:userUnit toUnit:ChTrackingUnitMMO];
    [[NSUserDefaults standardUserDefaults] setValue:transformedValue forKey:kMinHealthyChKey];
}

- (void)maxSliderValueChanged:(UISlider *)sender {
    NSInteger userUnit = [IMHelper userChUnit];
    if(userUnit == ChTrackingUnitMG) {
        sender.value = roundf(sender.value);
    } else {
        sender.value = round(sender.value*2.0f)/2.0f;
    }
    
    NSNumber *transformedValue = [IMHelper convertCholesterolValue:[NSNumber numberWithFloat:sender.value] fromUnit:userUnit toUnit:ChTrackingUnitMMO];
    [[NSUserDefaults standardUserDefaults] setValue:transformedValue forKey:kMaxHealthyChKey];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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
        cell.textLabel.text = NSLocalizedString(@"Cholesterol units", @"Cholesterol units");
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"mg/dL", @"mmoI/L"]];
        [segmentedControl addTarget:self action:@selector(changeCholesterolUnits:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = segmentedControl;
        
        [segmentedControl setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:kChTrackingUnitKey]];
    } else if(indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Min healthy", @"An option label for determining the lowest a cholesterol reading can be before being considered unhealthy");
        
        NSInteger userUnit = [IMHelper userChUnit];
        IMSlider *slider = [[IMSlider alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        slider.minimumValue = [[IMHelper convertCholesterolValue:[NSNumber numberWithFloat:0.0f] fromUnit:ChTrackingUnitMMO toUnit:userUnit] floatValue];
        slider.maximumValue = [[IMHelper convertCholesterolValue:[NSNumber numberWithFloat:10.0f] fromUnit:ChTrackingUnitMMO toUnit:userUnit] floatValue];
        
        NSNumber *minValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyChKey];
        slider.value = [[IMHelper convertCholesterolValue:minValue fromUnit:ChTrackingUnitMMO toUnit:userUnit] floatValue];
        cell.accessoryView = slider;
        
        [slider addTarget:self action:@selector(minSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    } else if(indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Max healthy", @"An option label for determining the highest a cholesterol reading can be before being considered unhealthy");
        
        NSInteger userUnit = [IMHelper userChUnit];
        IMSlider *slider = [[IMSlider alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        slider.minimumValue = [[IMHelper convertCholesterolValue:[NSNumber numberWithFloat:6.0f] fromUnit:ChTrackingUnitMMO toUnit:userUnit] floatValue];
        slider.maximumValue = [[IMHelper convertCholesterolValue:[NSNumber numberWithFloat:16.0f] fromUnit:ChTrackingUnitMMO toUnit:userUnit] floatValue];
        
        NSNumber *minValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyChKey];
        slider.value = [[IMHelper convertCholesterolValue:minValue fromUnit:ChTrackingUnitMMO toUnit:userUnit] floatValue];
        cell.accessoryView = slider;
        
        [slider addTarget:self action:@selector(maxSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
