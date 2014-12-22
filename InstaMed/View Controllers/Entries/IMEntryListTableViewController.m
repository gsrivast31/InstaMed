//
//  IMEntryListTableViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 19/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEntryListTableViewController.h"
#import "IMEntryActivityInputViewController.h"
#import "IMEntryMedicineInputViewController.h"
#import "IMEntryMealInputViewController.h"
#import "IMEntryReadingInputViewController.h"
#import "IMEntryNoteInputViewController.h"

#import "IMEntryListTableViewCell.h"

@interface IMEntryListTableViewController ()

@property (nonatomic, strong) NSMutableArray* itemArray;

@end

@implementation IMEntryListTableViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select Type";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
    self.tableView.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    
    if(!self.navigationItem.leftBarButtonItem) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setImage:[[UIImage imageNamed:@"NavBarIconBack.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [backButton setTitle:self.navigationItem.backBarButtonItem.title forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10.0f, 0, 0)];
        [backButton setAdjustsImageWhenHighlighted:NO];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    }
    
    [self setupItemArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Responders, Events

- (void)dismissSelf:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
     
#pragma mark Helpers
- (void)setupItemArray {
    self.itemArray = [[NSMutableArray alloc] initWithCapacity:IMNoneType];
    self.itemArray[IMMedicineType] = @"Medication";
    self.itemArray[IMReadingType] = @"Reading";
    self.itemArray[IMFoodType] = @"Meal";
    self.itemArray[IMActivityType] = @"Activity";
    self.itemArray[IMNoteType] = @"Note";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"entryTypeCell";
    IMEntryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell configureCellForEventType:(enum IMEventType)indexPath.row eventName:[self.itemArray objectAtIndex:indexPath.row]];
    cell.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat screenHeight = screenRect.size.height - navigationBarHeight - statusBarHeight;
    
    return MAX(90.0f, screenHeight/(CGFloat)[self.itemArray count]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    enum IMEventType eventType = (enum IMEventType)indexPath.row;
    if (eventType == IMMedicineType) {
        IMEntryMedicineInputViewController* vc = [[IMEntryMedicineInputViewController alloc] init];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else if (eventType == IMFoodType) {
        IMEntryMealInputViewController* vc = [[IMEntryMealInputViewController alloc] init];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else if (eventType == IMActivityType) {
        IMEntryActivityInputViewController* vc = [[IMEntryActivityInputViewController alloc] init];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else if (eventType == IMNoteType) {
        IMEntryNoteInputViewController* vc = [[IMEntryNoteInputViewController alloc] init];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else if (eventType == IMReadingType) {
        IMEntryReadingInputViewController* vc = [[IMEntryReadingInputViewController alloc] init];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

@end
