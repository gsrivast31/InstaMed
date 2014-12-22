//
//  IMUserViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 14/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMUserViewController.h"
#import "IMCoreDataStack.h"
#import "IMUser.h"
#import "IMDisease.h"

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
@property (nonatomic, strong) NSArray *diseasesArray;
@property (nonatomic) BOOL trackHyperTension;
@property (nonatomic) BOOL trackDiabetes;
@end

@implementation IMUserViewController

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
        
        self.title = @"Edit User";
    } else {
        self.trackDiabetes = self.trackHyperTension = false;
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
    
    self.diseasesArray = @[@"Diabetes", @"Blood Pressure"];
    self.trackedDiseasesTable.dataSource = self;
    self.trackedDiseasesTable.delegate = self;
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

- (IBAction)saveUser:(id)sender {
    if (self.entry != nil) {
        [self updateUser];
    } else {
        [self insertUser];
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

    [coreDataStack saveContext];
}

- (void)updateUser {
    self.entry.name = self.name.text;
    self.entry.email = self.email.text;
    
    if (self.gender.selectedSegmentIndex == 1) {
        self.entry.gender = IMUserMale;
    } else if (self.gender.selectedSegmentIndex == 2) {
        self.entry.gender = IMUserFemale;
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

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.diseasesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"diseaseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = [self.diseasesArray objectAtIndex:indexPath.row];
    
    if (indexPath.row == IMDiabetes && self.trackDiabetes) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == IMHyperTension && self.trackHyperTension) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == IMHyperTension) {
        self.trackHyperTension = !self.trackHyperTension;
        if (self.trackHyperTension) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == IMDiabetes) {
        self.trackDiabetes = !self.trackDiabetes;
        if (self.trackDiabetes) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}


@end
