//
//  IMUserViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMUserViewController.h"
#import "IMRootViewController.h"
#import "IMCoreDataStack.h"
#import "IMUser.h"
#import "IMDisease.h"

#import "CAGradientLayer+IMGradients.h"

@interface IMUserViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profilePhoto;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirth;
@property (weak, nonatomic) IBOutlet UITextField *bloodGroup;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UITextField *weight;
@property (weak, nonatomic) IBOutlet UITextField *height;
@property (weak, nonatomic) IBOutlet UITextField *relationship;
@property (weak, nonatomic) IBOutlet UITableView *trackedDiseasesTable;

@property (nonatomic, strong) UIImage *pickedImage;
@property (nonatomic, strong) NSDate *pickedDate;
@property (nonatomic, strong) NSString *pickedBloodGroup;
@property (nonatomic, strong) NSArray *bloodGroupArray;
@property (nonatomic) BOOL trackHyperTension;
@property (nonatomic) BOOL trackDiabetes;
@property (nonatomic) BOOL trackCholesterol;
@property (nonatomic) BOOL trackWeight;
@end

@implementation IMUserViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.entry != nil) {
        self.name.text = self.entry.name;
        self.email.text = self.entry.email;
        self.bloodGroup.text = self.entry.bloodgroup;
        
        if (self.entry.gender == IMUserFemale)
            self.gender.selectedSegmentIndex = 1;
        else if (self.entry.gender == IMUserOther)
            self.gender.selectedSegmentIndex = 2;
        else
            self.gender.selectedSegmentIndex = 0;
        
        self.weight.text = [NSString stringWithFormat:@"%d", self.entry.weight];
        self.height.text = [NSString stringWithFormat:@"%d", self.entry.height];
        
        self.relationship.text = self.entry.relationship;
        
        self.pickedImage = [UIImage imageWithData:self.entry.profilePhoto];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.entry.dob];
        self.pickedDate = date;
        
        self.trackHyperTension = self.entry.trackingHyperTension;
        self.trackDiabetes = self.entry.trackingDiabetes;
        self.trackCholesterol = self.entry.trackingCholesterol;
        self.trackWeight = self.entry.trackingWeight;
        
        self.title = @"Edit User";
    } else {
        self.trackDiabetes = self.trackHyperTension = self.trackWeight = self.trackCholesterol = false;
        self.title = @"Add User";
        self.pickedImage = nil;
    }
    
    self.profilePhoto.layer.masksToBounds = YES;
    self.profilePhoto.layer.cornerRadius = CGRectGetWidth(self.profilePhoto.frame) / 2.0f;
    
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateDateOfBirth:) forControlEvents:UIControlEventValueChanged];
    [self.dateOfBirth setInputView:datePicker];
    
    UIPickerView* pickerView = [[UIPickerView alloc] init];
    self.bloodGroupArray = @[@"Do not know",@"A+",@"A-",@"B+",@"B-",@"AB+",@"A-",@"O+",@"O-"];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [self.bloodGroup setInputView:pickerView];
    
    self.trackedDiseasesTable.dataSource = self;
    self.trackedDiseasesTable.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(saveUser:)];
    
    CAGradientLayer *backgroundLayer = [CAGradientLayer sideGradientLayer];
    backgroundLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:backgroundLayer atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPickedImage:(UIImage *)pickedImage {
    _pickedImage = pickedImage;
    
    if (pickedImage == nil) {
        if (self.gender.selectedSegmentIndex == 1) {
            [self.profilePhoto setImage:[UIImage imageNamed:@"icn_female"] forState:UIControlStateNormal];
        } else {
            [self.profilePhoto setImage:[UIImage imageNamed:@"icn_male"] forState:UIControlStateNormal];
        }
    } else {
        [self.profilePhoto setImage:pickedImage forState:UIControlStateNormal];
    }
}

- (void)setPickedBloodGroup:(NSString *)pickedBloodGroup {
    _pickedBloodGroup = pickedBloodGroup;
    
    if (pickedBloodGroup == nil) {
        self.bloodGroup.text = [self.bloodGroupArray objectAtIndex:0];
    } else {
        self.bloodGroup.text = pickedBloodGroup;
    }
}

- (void)setPickedDate:(NSDate*)pickedDate {
    _pickedDate = pickedDate;
    
    if (pickedDate != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM, dd, yyyy"];
        self.dateOfBirth.text = [dateFormatter stringFromDate:pickedDate];
    }
}

- (void)updateDateOfBirth:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.dateOfBirth.inputView;
    self.pickedDate = picker.date;
}

- (void)updateTrackings {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey] isEqualToString:self.entry.guid]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.trackDiabetes forKey:kCurrentProfileTrackingDiabetesKey];
        [[NSUserDefaults standardUserDefaults] setBool:self.trackCholesterol forKey:kCurrentProfileTrackingCholesterolKey];
        [[NSUserDefaults standardUserDefaults] setBool:self.trackHyperTension forKey:kCurrentProfileTrackingBPKey];
        [[NSUserDefaults standardUserDefaults] setBool:self.trackWeight forKey:kCurrentProfileTrackingWeightKey];
        
        // Post a notification so that we can determine when linking occurs
        NSDictionary* info = @{@"name":self.entry.name,@"image":[UIImage imageWithData:self.entry.profilePhoto]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentProfileChangedNotification object:nil userInfo:info];
    }
}

- (IBAction)saveUser:(id)sender {
    if (self.entry != nil) {
        [self updateUser];
    } else {
        [self insertUser];
    }
    [self updateTrackings];
    
    if (self.entry != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsChangedNotification object:nil];
    }
    
    [self dismissSelf];
}

- (IBAction)cancel:(id)sender {
    [self dismissSelf];
}

- (IBAction)changeProfilePhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self promptForSource];
    } else {
        [self promptForPhotoRoll];
    }
}

- (void)insertUser {
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    IMUser *entry = [NSEntityDescription insertNewObjectForEntityForName:@"IMUser" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    entry.name = self.name.text;
    entry.email = self.email.text;
    
    if (self.gender.selectedSegmentIndex == 1) {
        entry.gender = IMUserFemale;
    } else if (self.gender.selectedSegmentIndex == 2) {
        entry.gender = IMUserOther;
    } else {
        entry.gender = IMUserMale;
    }
    
    entry.bloodgroup = self.pickedBloodGroup;
    entry.weight = [self.weight.text intValue];
    entry.height = [self.height.text intValue];
    entry.relationship = self.relationship.text;
    entry.profilePhoto = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    entry.dob = [self.pickedDate timeIntervalSince1970];
    entry.trackingDiabetes = self.trackDiabetes;
    entry.trackingHyperTension = self.trackHyperTension;
    entry.trackingWeight = self.trackWeight;
    entry.trackingCholesterol = self.trackCholesterol;

    [coreDataStack saveContext];
}

- (void)updateUser {
    self.entry.name = self.name.text;
    self.entry.email = self.email.text;
    
    if (self.gender.selectedSegmentIndex == 1) {
        self.entry.gender = IMUserFemale;
    } else if (self.gender.selectedSegmentIndex == 2) {
        self.entry.gender = IMUserOther;
    } else {
        self.entry.gender = IMUserMale;
    }
    
    self.entry.bloodgroup = self.pickedBloodGroup;
    self.entry.weight = [self.weight.text intValue];
    self.entry.height = [self.height.text intValue];
    self.entry.relationship = self.relationship.text;
    self.entry.profilePhoto = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    self.entry.dob = [self.pickedDate timeIntervalSince1970];
    self.entry.trackingDiabetes = self.trackDiabetes;
    self.entry.trackingHyperTension = self.trackHyperTension;
    self.entry.trackingCholesterol = self.trackCholesterol;
    self.entry.trackingWeight = self.trackWeight;
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    [coreDataStack saveContext];
}

#pragma mark UIImagePickerControllerDelegate

- (void)promptForSource {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Roll", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self promptForCamera];
        } else {
            [self promptForPhotoRoll];
        }
    }
}

- (void)promptForCamera {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)promptForPhotoRoll {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.pickedImage = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.bloodGroupArray count];
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.bloodGroupArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickedBloodGroup = [self.bloodGroupArray objectAtIndex:row];
}

#pragma mark Responders, Events

- (void)toggleBGTracking:(UISwitch *)sender {
    self.trackDiabetes = !self.trackDiabetes;
}

- (void)toggleBPTracking:(UISwitch *)sender {
    self.trackHyperTension = !self.trackHyperTension;
}

- (void)toggleCholesterolTracking:(UISwitch *)sender {
    self.trackCholesterol = !self.trackCholesterol;
}

- (void)toggleWeightTracking:(UISwitch *)sender {
    self.trackWeight = !self.trackWeight;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
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
        cell.textLabel.text = NSLocalizedString(@"Blood Glucose", @"A settings switch to track Blood Glucose");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl setOn:self.trackDiabetes];
        [switchControl addTarget:self action:@selector(toggleBGTracking:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
    } else if(indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Blood Pressure", @"A settings switch to track Blood Pressure");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl setOn:self.trackHyperTension];
        [switchControl addTarget:self action:@selector(toggleBPTracking:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
    } else if(indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Cholesterol", @"A settings switch to track Cholesterol");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl setOn:self.trackCholesterol];
        [switchControl addTarget:self action:@selector(toggleCholesterolTracking:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
    } else if(indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Weight", @"A settings switch to track weight");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl setOn:self.trackWeight];
        [switchControl addTarget:self action:@selector(toggleWeightTracking:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
