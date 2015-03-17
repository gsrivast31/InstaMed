//
//  IMSettingsGlucoseViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsGlucoseViewController.h"

@implementation IMSettingsGlucoseViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Glucose", nil);
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Logic
- (void)changeBGUnits:(UISegmentedControl *)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex] forKey:kBGTrackingUnitKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)minSliderValueChanged:(UISlider *)sender
{
    NSInteger userUnit = [IMHelper userBGUnit];
    if(userUnit == BGTrackingUnitMG)
    {
        sender.value = roundf(sender.value);
    }
    else
    {
        sender.value = round(sender.value*2.0f)/2.0f;
    }
    
    NSNumber *transformedValue = [IMHelper convertBGValue:[NSNumber numberWithFloat:sender.value] fromUnit:userUnit toUnit:BGTrackingUnitMMO];
    [[NSUserDefaults standardUserDefaults] setValue:transformedValue forKey:kMinHealthyBGKey];
}
- (void)maxSliderValueChanged:(UISlider *)sender
{
    NSInteger userUnit = [IMHelper userBGUnit];
    if(userUnit == BGTrackingUnitMG)
    {
        sender.value = roundf(sender.value);
    }
    else
    {
        sender.value = round(sender.value*2.0f)/2.0f;
    }
    
    NSNumber *transformedValue = [IMHelper convertBGValue:[NSNumber numberWithFloat:sender.value] fromUnit:userUnit toUnit:BGTrackingUnitMMO];
    [[NSUserDefaults standardUserDefaults] setValue:transformedValue forKey:kMaxHealthyBGKey];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
        cell.textLabel.text = NSLocalizedString(@"BG units", @"Blood glucose units");
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"mg/dL", @"mmoI/L"]];
        [segmentedControl addTarget:self action:@selector(changeBGUnits:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = segmentedControl;
        
        [segmentedControl setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey]];
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Min healthy", @"An option label for determining the lowest a blood glucose reading can be before being considered unhealthy");
        
        NSInteger userUnit = [IMHelper userBGUnit];
        IMSlider *slider = [[IMSlider alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        slider.minimumValue = [[IMHelper convertBGValue:[NSNumber numberWithFloat:0.0f] fromUnit:BGTrackingUnitMMO toUnit:userUnit] floatValue];
        slider.maximumValue = [[IMHelper convertBGValue:[NSNumber numberWithFloat:10.0f] fromUnit:BGTrackingUnitMMO toUnit:userUnit] floatValue];
        
        NSNumber *minValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyBGKey];
        slider.value = [[IMHelper convertBGValue:minValue fromUnit:BGTrackingUnitMMO toUnit:userUnit] floatValue];
        cell.accessoryView = slider;
        
        [slider addTarget:self action:@selector(minSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text = NSLocalizedString(@"Max healthy", @"An option label for determining the highest a blood glucose reading can be before being considered unhealthy");
        
        NSInteger userUnit = [IMHelper userBGUnit];
        IMSlider *slider = [[IMSlider alloc] initWithFrame:CGRectMake(0, 0, 110, 44)];
        slider.minimumValue = [[IMHelper convertBGValue:[NSNumber numberWithFloat:6.0f] fromUnit:BGTrackingUnitMMO toUnit:userUnit] floatValue];
        slider.maximumValue = [[IMHelper convertBGValue:[NSNumber numberWithFloat:16.0f] fromUnit:BGTrackingUnitMMO toUnit:userUnit] floatValue];
        
        NSNumber *minValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyBGKey];
        slider.value = [[IMHelper convertBGValue:minValue fromUnit:BGTrackingUnitMMO toUnit:userUnit] floatValue];
        cell.accessoryView = slider;
        
        [slider addTarget:self action:@selector(maxSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
