//
//  IMUserAddEditViewController.m
//  HealthMemoir
//
//  Created by Ranjeet on 3/16/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMUserAddEditViewController.h"
#import "IMUser.h"
#import <RETableViewManager/RETableViewManager.h>
#import "CAGradientLayer+IMGradients.h"

@interface IMUserAddEditViewController () <RETableViewManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong, readwrite) RETableViewManager* manager;

@property (strong, readwrite, nonatomic) RETextItem *nameItem;
@property (strong, readwrite, nonatomic) RETextItem *emailItem;
@property (strong, readwrite, nonatomic) RETextItem *relationItem;
@property (strong, readwrite, nonatomic) RENumberItem *ageItem;
@property (strong, readwrite, nonatomic) RESegmentedItem *genderItem;

@property (strong, readwrite, nonatomic) REPickerItem* bloodGroupItem;
@property (strong, readwrite, nonatomic) RENumberItem* weightItem;
@property (strong, readwrite, nonatomic) RENumberItem* heightItem;

@property (strong, readwrite, nonatomic) REBoolItem* diabetesItem;
@property (strong, readwrite, nonatomic) REBoolItem* bpItem;
@property (strong, readwrite, nonatomic) REBoolItem* cholesterolItem;
@property (strong, readwrite, nonatomic) REBoolItem* wtItem;

@property (nonatomic, strong) UIImage *pickedImage;
@property (nonatomic, strong) UIImageView *profileImageView;

@end

@implementation IMUserAddEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 205.0f)];
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        self.profileImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.profileImageView.image = [UIImage imageNamed:@"icn_male"];
        self.profileImageView.layer.masksToBounds = YES;
        self.profileImageView.layer.cornerRadius = 50.0;
        self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.profileImageView.layer.borderWidth = 3.0f;
        self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.profileImageView.layer.shouldRasterize = YES;
        self.profileImageView.clipsToBounds = YES;
        
        UILabel* changeUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        changeUserLabel.text = @"Tap to change profile photo";
        changeUserLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        changeUserLabel.backgroundColor = [UIColor clearColor];
        changeUserLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        changeUserLabel.userInteractionEnabled = YES;
        [changeUserLabel sizeToFit];
        changeUserLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeProfilePhoto:)];
        [changeUserLabel addGestureRecognizer:tapGesture];
        
        [view addSubview:self.profileImageView];
        [view addSubview:changeUserLabel];
        view;
    });

    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    [self addTableEntries];
    
    if (self.entry) {
        self.title = @"Edit User";
        self.pickedImage = [UIImage imageWithData:self.entry.profilePhoto];
    } else {
        self.title = @"Add User";
        self.pickedImage = nil;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(saveUser:)];
    
}

- (void)dismissSelf {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPickedImage:(UIImage *)pickedImage {
    _pickedImage = pickedImage;
    
    if (pickedImage == nil) {
        if (self.genderItem.value == 1) {
            _pickedImage = [UIImage imageNamed:@"icn_female"];
        } else {
            _pickedImage = [UIImage imageNamed:@"icn_male"];
        }
    }
    [self.profileImageView setImage:_pickedImage];
}

- (void)changeProfilePhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self promptForSource];
    } else {
        [self promptForPhotoRoll];
    }
}

- (void)updateTrackings {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey] isEqualToString:self.entry.guid]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.diabetesItem.value forKey:kCurrentProfileTrackingDiabetesKey];
        [[NSUserDefaults standardUserDefaults] setBool:self.cholesterolItem.value forKey:kCurrentProfileTrackingCholesterolKey];
        [[NSUserDefaults standardUserDefaults] setBool:self.bpItem.value forKey:kCurrentProfileTrackingBPKey];
        [[NSUserDefaults standardUserDefaults] setBool:self.wtItem.value forKey:kCurrentProfileTrackingWeightKey];
        
        // Post a notification so that we can determine when linking occurs
        NSDictionary* info = @{@"name":self.entry.name,@"image":[UIImage imageWithData:self.entry.profilePhoto]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentProfileChangedNotification object:nil userInfo:info];
    }
}

- (void)insertUser {
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    IMUser *entry = [NSEntityDescription insertNewObjectForEntityForName:@"IMUser" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    entry.name = self.nameItem.value;
    entry.email = self.emailItem.value;
    entry.age = [self.ageItem.value intValue];
    entry.relationship = self.relationItem.value;
    entry.gender = self.genderItem.value;
    entry.weight = [self.weightItem.value intValue];
    entry.height = [self.heightItem.value intValue];
    entry.bloodgroup = [self.bloodGroupItem.value objectAtIndex:0];
    entry.trackingDiabetes = self.diabetesItem.value;
    entry.trackingHyperTension = self.bpItem.value;
    entry.trackingWeight = self.wtItem.value;
    entry.trackingCholesterol = self.cholesterolItem.value;
    entry.profilePhoto = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    
    [coreDataStack saveContext];
}

- (void)updateUser {
    self.entry.name = self.nameItem.value;
    self.entry.email = self.emailItem.value;
    self.entry.age = [self.ageItem.value intValue];
    self.entry.relationship = self.relationItem.value;
    self.entry.gender = self.genderItem.value;
    self.entry.weight = [self.weightItem.value intValue];
    self.entry.height = [self.heightItem.value intValue];
    self.entry.bloodgroup = [self.bloodGroupItem.value objectAtIndex:0];
    self.entry.trackingDiabetes = self.diabetesItem.value;
    self.entry.trackingHyperTension = self.bpItem.value;
    self.entry.trackingWeight = self.wtItem.value;
    self.entry.trackingCholesterol = self.cholesterolItem.value;
    self.entry.profilePhoto = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    [coreDataStack saveContext];
}

- (BOOL)validate {
    NSArray *managerErrors = self.manager.errors;
    if (managerErrors.count > 0) {
        NSMutableArray *errors = [NSMutableArray array];
        for (NSError *error in managerErrors) {
            [errors addObject:error.localizedDescription];
        }
        NSString *errorString = [errors componentsJoinedByString:@"\n"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (IBAction)saveUser:(id)sender {
    if ([self validate] == NO) {
        return;
    }
    
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

#pragma mark -

- (void)addTableEntries {
    [self addGeneralSection];
    [self addHealthSection];
    [self addTrackingsSection];
}

- (void)addGeneralSection {
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"General Info"];
    [self.manager addSection:section];
    
    self.nameItem = [RETextItem itemWithTitle:@"Name" value:self.entry?self.entry.name:nil placeholder:@"E.g. Gaurav Srivastava"];
    self.nameItem.keyboardType = UIKeyboardTypeAlphabet;
    self.nameItem.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.nameItem.validators = @[@"presence"];
    
    self.emailItem = [RETextItem itemWithTitle:@"Email" value:self.entry?self.entry.email:nil  placeholder:@"E.g. abc@xyz.com"];
    self.emailItem.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailItem.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailItem.validators = @[@"email"];
    
    self.relationItem = [RETextItem itemWithTitle:@"Relation" value:self.entry?self.entry.relationship:nil  placeholder:@"E.g. Self, Father, Mother etc."];
    self.relationItem.validators = @[@"presence"];
    
    self.ageItem = [RENumberItem itemWithTitle:@"Age" value:self.entry&&self.entry.age?[NSString stringWithFormat:@"%d", self.entry.age]:nil placeholder:nil];
    self.genderItem = [RESegmentedItem itemWithTitle:nil segmentedControlTitles:@[@"Male", @"Female", @"Other"] value:self.entry?self.entry.gender:0];
    
    self.genderItem.tintColor = [UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f];
    
    [section addItem:self.nameItem];
    [section addItem:self.emailItem];
    [section addItem:self.relationItem];
    [section addItem:self.ageItem];
    [section addItem:self.genderItem];
}

- (void)addHealthSection {
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"Health Info"];
    [self.manager addSection:section];
    
    NSArray* bloodGroupArray = @[@"Do not know",@"A+",@"A-",@"B+",@"B-",@"AB+",@"A-",@"O+",@"O-"];
    NSString* currentBG = (self.entry&&self.entry.bloodgroup)?self.entry.bloodgroup:bloodGroupArray[0];
    self.bloodGroupItem = [REPickerItem itemWithTitle:@"Blood Group" value:@[currentBG] placeholder:nil options:@[bloodGroupArray]];
    self.bloodGroupItem.inlinePicker = YES;
    self.weightItem = [RENumberItem itemWithTitle:@"Weight(in kgs)" value:self.entry&&self.entry.weight?[NSString stringWithFormat:@"%d", self.entry.weight]:nil placeholder:nil];
    self.heightItem = [RENumberItem itemWithTitle:@"Height(in cms)" value:self.entry&&self.entry.height?[NSString stringWithFormat:@"%d", self.entry.height]:nil placeholder:nil];
    
    [section addItem:self.bloodGroupItem];
    [section addItem:self.weightItem];
    [section addItem:self.heightItem];
}

- (void)addTrackingsSection {
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"Trackings"];
    [self.manager addSection:section];
    
    self.diabetesItem = [REBoolItem itemWithTitle:@"Diabetes" value:self.entry?self.entry.trackingDiabetes:NO];
    self.bpItem = [REBoolItem itemWithTitle:@"Blood Pressure" value:self.entry?self.entry.trackingHyperTension:NO];
    self.cholesterolItem = [REBoolItem itemWithTitle:@"Cholesterol" value:self.entry?self.entry.trackingCholesterol:NO];
    self.wtItem = [REBoolItem itemWithTitle:@"Weight" value:self.entry?self.entry.trackingWeight:NO];
    
    [section addItem:self.diabetesItem];
    [section addItem:self.bpItem];
    [section addItem:self.cholesterolItem];
    [section addItem:self.wtItem];
}

#pragma mark RETableViewManagerDelegate

- (void)tableView:(UITableView *)tableView willLoadCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

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

@end
