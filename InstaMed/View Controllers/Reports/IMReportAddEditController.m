//
//  IMReportAddEditController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportAddEditController.h"
#import "IMReport.h"
#import "IMImage.h"
#import "IMCoreDataStack.h"
#import "IMReportImageViewCell.h"
#import "IMMediaController.h"

#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

@interface IMReportAddEditController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *doctorTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (nonatomic, strong) NSDate *pickedDate;
@property (nonatomic, strong) NSMutableArray *reportImages;
@property (nonatomic, strong) UIImageView *selectedImageView;
@end

@implementation IMReportAddEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.entry != nil) {
        self.titleTextField.text = self.entry.title;
        self.doctorTextField.text = self.entry.doctorName;
        self.pickedDate = [NSDate dateWithTimeIntervalSince1970:self.entry.date];
        self.title = @"Edit Report";
    } else {
        self.title = @"Add Report";
    }
    
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];
    [self.dateTextField setInputView:datePicker];
    
    self.reportImages = [[NSMutableArray alloc] initWithArray:[self.entry.images allObjects]];
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveReport:(id)sender {
    if (self.entry != nil) {
        [self updateReport];
    } else {
        [self insertReport];
    }
    [self dismissSelf];
}

- (IBAction)cancel:(id)sender {
    [self dismissSelf];
}

- (void)setPickedDate:(NSDate*)pickedDate {
    _pickedDate = pickedDate;
    
    if (pickedDate != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM, dd, yyyy"];
        self.dateTextField.text = [dateFormatter stringFromDate:pickedDate];
    }
}

- (void)updateDate:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.dateTextField.inputView;
    self.pickedDate = picker.date;
}

- (void)insertReport {
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    IMReport *entry = [NSEntityDescription insertNewObjectForEntityForName:@"IMReport" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    entry.title = self.titleTextField.text;
    entry.type = self.reportType;
    entry.doctorName = self.doctorTextField.text;
    entry.date = [self.pickedDate timeIntervalSince1970];
    entry.images = [[NSSet alloc] initWithArray:self.reportImages];
    
    [coreDataStack saveContext];
}

- (void)updateReport {
    self.entry.title = self.titleTextField.text;
    self.entry.type = self.reportType;
    self.entry.doctorName = self.doctorTextField.text;
    self.entry.date = [self.pickedDate timeIntervalSince1970];
    self.entry.images = [[NSSet alloc] initWithArray:self.reportImages];

    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    [coreDataStack saveContext];
}

#pragma mark UINavigationControllerDelegate

#pragma mark UIImagePickerControllerDelegate

- (void)promptForSource {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Roll", nil];
    
    [actionSheet showInView:self.view];
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

- (void)addImageObject:(NSString*)filePath {
    IMImage *entry = [NSEntityDescription insertNewObjectForEntityForName:@"IMImage" inManagedObjectContext:[IMCoreDataStack defaultStack].managedObjectContext];
    
    entry.imagePath = filePath;
    [self.reportImages addObject:entry];
}

- (void) saveImage:(UIImage*)image {

    NSString * timeStamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString* filePath = [NSString stringWithFormat:@"image_%@.jpeg", timeStamp];
    
    __weak typeof(self) weakSelf = self;
    
    [[IMMediaController sharedInstance] saveImage:image withFilename:filePath success:^{
        __strong typeof(weakSelf) strongSelf = self;

        [strongSelf addImageObject:filePath];
        [strongSelf.imagesCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[strongSelf.reportImages count]-1 inSection:0]]];
    } failure:^(NSError *error) {
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self saveImage:info[UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addReportImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self promptForSource];
    } else {
        [self promptForPhotoRoll];
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self promptForCamera];
        } else {
            [self promptForPhotoRoll];
        }
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.reportImages count] + 1;
}

- (void)addBorderToCell:(UICollectionViewCell*)cell {
    [cell.layer setBorderColor:[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f].CGColor];
    [cell.layer setBorderWidth:1.0f];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.reportImages count]) {
        UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dummyCell" forIndexPath:indexPath];
        
        //[self addBorderToCell:cell];

        return cell;
    } else {
        IMReportImageViewCell* cell = (IMReportImageViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"reportImageCell" forIndexPath:indexPath];
        IMImage* image = [self.reportImages objectAtIndex:indexPath.row];
        [cell configureCellForEntry:image.imagePath];
        
        return cell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.reportImages count]) {
        self.selectedImageView = nil;
        [self addReportImage];
    } else {
        IMImage* reportImage = (IMImage*)[self.reportImages objectAtIndex:indexPath.row];
        
        IMReportImageViewCell* cell = (IMReportImageViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        self.selectedImageView = cell.reportImageView;

        UIImage *image = [[IMMediaController sharedInstance] imageWithFilename:reportImage.imagePath];

        TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:image];
        viewController.transitioningDelegate = self;
        
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(160, 200);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class])
    {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.selectedImageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:TGRImageViewController.class])
    {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.selectedImageView];
    }
    return nil;
}


@end
