//
//  IMReportAddEditViewController.m
//  InstaMed
//
//  Created by Ranjeet on 3/16/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportAddEditViewController.h"
#import <RETableViewManager/RETableViewManager.h>
#import "KRLCollectionViewGridLayout.h"
#import "IMReportImageCell.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
#import "IMMediaController.h"
#import "IMImage.h"

@interface IMReportAddEditViewController () <RETableViewManagerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong, readwrite) RETableViewManager* manager;

@property(nonatomic, strong, readwrite) RETextItem* nameItem;
@property(nonatomic, strong, readwrite) REDateTimeItem* dateItem;
@property(nonatomic, strong, readwrite) RETextItem* doctorNameItem;

@property (nonatomic, strong) NSMutableArray *reportImages;

@end

@implementation IMReportAddEditViewController

static NSString * const reuseIdentifier = @"reportImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.entry != nil) {
        self.title = @"Edit Report";
        self.reportImages = [[NSMutableArray alloc] initWithArray:[self.entry.images allObjects]];
    } else {
        self.title = @"Add Report";
        self.reportImages = [[NSMutableArray alloc] init];
    }

    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    [self addTableEntries];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.layout.numberOfItemsPerLine = 2;
    self.layout.aspectRatio = 1;
    self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.layout.interitemSpacing = 10;
    self.layout.lineSpacing = 10;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(saveReport:)];
    
    self.tableView.backgroundColor = self.collectionView.backgroundColor = [UIColor whiteColor];
    self.addImageButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:213/255.0 blue:161/255.0 alpha:1];
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

- (void)insertReport {
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    IMReport *entry = [NSEntityDescription insertNewObjectForEntityForName:@"IMReport" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    entry.title = self.nameItem.value;
    entry.type = self.reportType;
    entry.doctorName = self.doctorNameItem.value;
    entry.date = [self.dateItem.value timeIntervalSince1970];
    entry.images = [[NSSet alloc] initWithArray:self.reportImages];
    
    [coreDataStack saveContext];
}

- (void)updateReport {
    self.entry.title = self.nameItem.value;
    self.entry.type = self.reportType;
    self.entry.doctorName = self.doctorNameItem.value;
    self.entry.date = [self.dateItem.value timeIntervalSince1970];
    self.entry.images = [[NSSet alloc] initWithArray:self.reportImages];
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    [coreDataStack saveContext];
}

- (void)addTableEntries {
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"General Info"];
    [self.manager addSection:section];
    
    self.nameItem = [RETextItem itemWithTitle:@"Report Name" value:self.entry?self.entry.title:nil placeholder:nil];
    self.doctorNameItem = [RETextItem itemWithTitle:@"Doctor's Name" value:self.entry?self.entry.doctorName:nil placeholder:nil];
    self.dateItem = [REDateTimeItem itemWithTitle:@"Report Date" value:self.entry?[NSDate dateWithTimeIntervalSince1970:self.entry.date]:[NSDate date] placeholder:nil format:@"MM/dd/yyyy" datePickerMode:UIDatePickerModeDate];
    [section addItem:self.nameItem];
    [section addItem:self.doctorNameItem];
    [section addItem:self.dateItem];
    
    RETableViewSection* imagesSection = [RETableViewSection sectionWithHeaderTitle:@"Images"];
    [self.manager addSection:imagesSection];
}

- (KRLCollectionViewGridLayout *)layout {
    return (id)self.collectionView.collectionViewLayout;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.reportImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IMImage* image = [self.reportImages objectAtIndex:indexPath.row];
    IMReportImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configureCellWithFileName:image.imagePath];
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    IMReportImageCell* cell = (IMReportImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
    JTSImageInfo* imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = cell.imageView.image;
    imageInfo.referenceRect = cell.imageView.frame;
    imageInfo.referenceView = cell.imageView.superview;
    imageInfo.referenceContentMode = cell.imageView.contentMode;
    imageInfo.referenceCornerRadius = cell.imageView.layer.cornerRadius;
    
    JTSImageViewController* imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (IBAction)addImage:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self promptForSource];
    } else {
        [self promptForPhotoRoll];
    }
}

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
        [strongSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[strongSelf.reportImages count]-1 inSection:0]]];
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

@end
