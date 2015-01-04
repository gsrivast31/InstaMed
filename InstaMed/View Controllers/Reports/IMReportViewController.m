//
//  IMReportViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMReportViewController.h"
#import "IMReportAddEditController.h"
#import "IMCoreDataStack.h"
#import "IMReportViewCell.h"

#import "CAGradientLayer+IMGradients.h"

@interface IMReportViewController () <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@end

@implementation IMReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    [self.fetchedResultsController performFetch:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exportCard:) name:kExportReportNotification object:nil] ;
    
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kExportReportNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)exportCard:(NSNotification*)notification {
    NSDictionary* info = notification.userInfo;
    NSString* title = [info valueForKey:@"title"];
    NSString* date = [info valueForKey:@"date"];
    UIImage* image = [info valueForKey:@"image"];
    NSString* message = [NSString stringWithFormat:@"\n Report Name: %@\n"
                         "\n Report Date: %@\n", title, date];
    NSArray* objectsToShare = @[message, image];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    controller.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"reportViewCell";
    IMReportViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    cell.backgroundColor = [UIColor clearColor];
    IMReport *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureCellForEntry:entry];
    
    return cell;
}

#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    IMReport *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    [[coreDataStack managedObjectContext] deleteObject:entry];
    [coreDataStack saveContext];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UINavigationController *navigationController = segue.destinationViewController;
    IMReportAddEditController *entryViewController = (IMReportAddEditController *)navigationController.topViewController;
    entryViewController.reportType = self.reportType;

    if ([segue.identifier isEqualToString:@"edit"]) {
        entryViewController.entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else if ([segue.identifier isEqualToString:@"add"]) {
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (NSFetchRequest *)entryListFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IMReport"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %d && userGuid = %@", self.reportType, currentUserGuid];
    
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self entryListFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
