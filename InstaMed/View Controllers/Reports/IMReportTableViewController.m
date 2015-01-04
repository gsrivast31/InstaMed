//
//  IMReportTableViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportTableViewController.h"
#import "IMReportTableViewCell.h"
#import "IMReportViewController.h"
#import "IMReport.h"

#import "CAGradientLayer+IMGradients.h"

@interface IMReportTableViewController ()

@property (nonatomic, strong) NSMutableArray* itemArray;

@end

@implementation IMReportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Reports";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
    
    self.tableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    [self setupItemArray];
    
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
    
    CAGradientLayer *backgroundLayer = [CAGradientLayer sideGradientLayer];
    backgroundLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:backgroundLayer atIndex:0];
    [self.tableView.layer insertSublayer:backgroundLayer atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupItemArray {
    self.itemArray = [[NSMutableArray alloc] initWithCapacity:IMReportAll];
    self.itemArray[IMReportPhysician] = @"Physicians";
    self.itemArray[IMReportLabResults] = @"Lab Results";
    self.itemArray[IMReportSpecialist] = @"Specialists";
    self.itemArray[IMReportDrugsAndPrescriptions] = @"Drugs and Prescriptions";
    self.itemArray[IMReportHospitalAdmissions] = @"Hospital Admissions";
    self.itemArray[IMReportMedicalHistory] = @"Medical History";
    self.itemArray[IMReportOther] = @"Other";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat screenHeight = screenRect.size.height - navigationBarHeight - statusBarHeight;
    
    return MAX(60.0f, screenHeight/(CGFloat)[self.itemArray count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"reportTableCell";
    IMReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell configureCellForEntry:[self.itemArray objectAtIndex:indexPath.row] forIndex:indexPath.row];
//    cell.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     UINavigationController* navigationController = (UINavigationController*)segue.destinationViewController;
     IMReportViewController* reportViewController = (IMReportViewController*)navigationController.topViewController;

     NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
     [reportViewController setReportType:indexPath.row];
     [reportViewController setTitle:[self.itemArray objectAtIndex:indexPath.row]];
}

@end
