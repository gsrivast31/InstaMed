//
//  IMExportViewController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 01/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "MBProgressHUD.h"

#import "IMExportViewController.h"
#import "IMAppDelegate.h"
#import "IMEventController.h"

#import "IMEvent.h"
#import "IMMedicine.h"
#import "IMActivity.h"
#import "IMMeal.h"
#import "IMNote.h"
#import "IMBGReading.h"
#import "IMBPReading.h"
#import "IMCholesterolReading.h"
#import "IMWeightReading.h"

#define kExportTypeEmail    0
#define kExportTypeAirPrint 1

@interface IMExportViewController ()
{
    OrderedDictionary *reportData;
    NSMutableDictionary *selectedMonths;
    
    BOOL exportPDF, exportCSV;
    BOOL exportActivity, exportMeal, exportGlucose, exportWeight, exportBP, exportCholesterol;
    
    NSDateFormatter *dateFormatter, *longDateFormatter;
    NSDateFormatter *timeFormatter;
}
@property (nonatomic, strong) IMViewControllerMessageView *noReportsMessageView;

// Logic
- (NSArray *)fetchEventsFromDate:(NSDate *)fromDate
                          toDate:(NSDate *)toDate
                         withMOC:(NSManagedObjectContext *)moc;

@end

@implementation IMExportViewController

#pragma mark - Setup
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Export", nil);
        
        exportPDF = YES;
        exportCSV = NO;
        
        exportActivity = exportMeal = YES;
        
        exportGlucose = [IMHelper includeGlucoseReadings];
        exportCholesterol = [IMHelper includeCholesterolReadings];
        exportBP = [IMHelper includeBPReadings];
        exportWeight = [IMHelper includeWeightReadings];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        longDateFormatter = [[NSDateFormatter alloc] init];
        [longDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];

        reportData = nil;
        selectedMonths = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Export", nil) style:UIBarButtonItemStylePlain target:self action:@selector(performExport:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadViewData:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)reloadViewData:(NSNotification *)note {
    [super reloadViewData:note];
    
    reportData = [self fetchEvents];
    [self refreshView];
}

- (void)refreshView {
    if(!self.noReportsMessageView) {
        self.noReportsMessageView = [IMViewControllerMessageView addToViewController:self
                                                                           withTitle:NSLocalizedString(@"No Reports", nil)
                                                                          andMessage:NSLocalizedString(@"You currently don't have any reports to export.", nil)];
    }

    if(!reportData) {
        self.noReportsMessageView.hidden = NO;
        //self.tableView.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.noReportsMessageView.hidden = YES;
        //self.tableView.hidden = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)performExport:(id)sender {
    NSInteger totalMonthsSelected = 0;
    for(NSString *month in [selectedMonths allKeys]) {
        if([[selectedMonths objectForKey:month] boolValue]) {
            totalMonthsSelected ++;
        }
    }
    
    if((exportPDF || exportCSV) && (exportActivity || exportBP || exportCholesterol || exportMeal || exportGlucose || exportWeight)) {
        if(reportData && totalMonthsSelected) {
            /*UIActionSheet *actionSheet = nil;
            if ([UIPrintInteractionController isPrintingAvailable]) {
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"Dropbox", nil), NSLocalizedString(@"Email", nil), NSLocalizedString(@"AirPrint", nil), nil];
            } else {
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"Dropbox", nil), NSLocalizedString(@"Email", nil), nil];
            }
            [actionSheet showInView:self.view];*/
            NSString *date = [longDateFormatter stringFromDate:[NSDate date]];
            NSString* message = [NSString stringWithFormat:NSLocalizedString(@"HealthMemoir Export - %@", nil), date];
            
            NSMutableArray* objectsToShare = [[NSMutableArray alloc] init];
            [objectsToShare addObject:message];
            if(exportCSV) {
                NSData *csvData = [self generateCSVData];
                [objectsToShare addObject:csvData];
            }
            if(exportPDF) {
                NSData *pdfData = [self generatePDFData];
                [objectsToShare addObject:pdfData];
            }
            
            NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                            UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,
                                            UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            controller.excludedActivityTypes = excludedActivities;
            
            [self presentViewController:controller animated:YES completion:nil];

            
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:NSLocalizedString(@"You must select at least one month to export", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    } else {
        if (!exportPDF && !exportCSV) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:NSLocalizedString(@"You must select at least one format to export", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:NSLocalizedString(@"You must select at least one thing to export", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)triggerExport:(NSInteger)type {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *date = [longDateFormatter stringFromDate:[NSDate date]];
        
        NSData *csvData = [self generateCSVData];
        NSData *pdfData = [self generatePDFData];
        
        if(type == kExportTypeEmail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Here's your HealthMemoir data export, generated on %@.", nil), date];
                MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
                controller.mailComposeDelegate = self;
                [controller setSubject:[NSString stringWithFormat:NSLocalizedString(@"HealthMemoir Export - %@", nil), date]];
                [controller setMessageBody:message isHTML:NO];
                if(exportCSV) {
                    [controller addAttachmentData:csvData mimeType:@"text/csv" fileName:[NSString stringWithFormat:@"%@ Export.csv", date]];
                }
                if(exportPDF) {
                    [controller addAttachmentData:pdfData mimeType:@"text/pdf" fileName:[NSString stringWithFormat:@"%@ Export.pdf", date]];
                }
                
                if (controller) {
                    [self presentViewController:controller animated:YES completion:nil];
                }
            });
        } else if(type == kExportTypeAirPrint) {
            UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
            printController.delegate = self;
            
            NSMutableArray *printingItems = [NSMutableArray array];
            if(exportCSV) [printingItems addObject:csvData];
            if(exportPDF) [printingItems addObject:pdfData];
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = @"HealthMemoir Export";
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printController.printInfo = printInfo;
            printController.showsPageRange = YES;
            printController.printingItems = printingItems;

            dispatch_async(dispatch_get_main_queue(), ^{
                [printController presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {

                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    if(!completed && error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                            message:NSLocalizedString(@"There was an error while printing your report", nil)
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                }];
            });
        }
    });
}

#pragma mark - Logic
- (OrderedDictionary *)fetchEvents {
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    
    if(moc) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMEvent" inManagedObjectContext:moc];
        [request setEntity:entity];
        [request setSortDescriptors:@[sortDescriptor]];
        
        NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userGuid = %@", currentUserGuid];
        [request setPredicate:predicate];

        //[request setReturnsObjectsAsFaults:NO];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        
        if(!error) {
            NSDateFormatter *dateKeyFormatter = [[NSDateFormatter alloc] init];
            [dateKeyFormatter setDateFormat:@"MMM yyyy"];
            
            OrderedDictionary *dictionary = [[OrderedDictionary alloc] init];
            for(IMEvent *event in objects) {
                NSString *date = [dateKeyFormatter stringFromDate:event.timestamp];
                if(date) {
                    if(![dictionary objectForKey:date]) {
                        NSDate *startDate = [(NSDate *)event.timestamp dateAtStartOfMonth];
                        NSDate *endDate = [startDate dateAtEndOfMonth];

                        if(startDate && endDate) {
                            [dictionary setObject:@{@"startDate": startDate, @"endDate": endDate} forKey:date];
                        }
                    }
                    
                    [selectedMonths setValue:[NSNumber numberWithBool:YES] forKey:date];
                }
                
                // Re-fault this object to conserve on memory
                [moc refreshObject:event mergeChanges:NO];
            }
            
            if([[dictionary allKeys] count]) {
                return dictionary;
            }
        }
    }
    
    return nil;
}

- (NSArray *)fetchEventsFromDate:(NSDate *)fromDate
                          toDate:(NSDate *)toDate
                         withMOC:(NSManagedObjectContext *)moc {
    __block NSArray *returnArray = nil;
    
    if(moc) {
        [moc performBlockAndWait:^{
            NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ && timestamp <= %@ && userGuid = %@", fromDate, toDate, currentUserGuid];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
            
            returnArray = [[IMEventController sharedInstance] fetchEventsWithPredicate:predicate
                                                                       sortDescriptors:@[sortDescriptor]
                                                                             inContext:moc];
        }];
    }
    
    return returnArray;
}

- (NSData *)generateCSVData {
    __block NSData *returnData = nil;
    
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] newPrivateContext];
    if(moc) {
        [moc performBlockAndWait:^{
            
            NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
            NSNumberFormatter *glucoseFormatter = [IMHelper glucoseNumberFormatter];
            NSNumberFormatter *cholesterolFormatter = [IMHelper cholesterolNumberFormatter];
            
            NSString *data = @"Month";
            data = [data stringByAppendingString:@",Total Activity"];
            data = [data stringByAppendingString:@",Total Grams"];
            data = [data stringByAppendingString:@",Glucose Avg.,Glucose (Lowest),Glucose (Highest),Glucose (Avg. Deviation)"];
            data = [data stringByAppendingString:@",Cholesterol Avg., Cholesterol (Lowest), Cholesterol (Highest), Cholesterol (Avg. Deviation)"];
            data = [data stringByAppendingString:@",Weight (Lowest), Weight (Highest)"];
            data = [data stringByAppendingString:@",Blood Pressure (Lowest), Blood Pressure (Highest)"];
            for(NSString *month in [reportData reverseKeyEnumerator]) {
                @autoreleasepool {
                    NSDictionary *monthData = [reportData objectForKey:month];
                    if([[selectedMonths objectForKey:month] boolValue]) {
                        NSArray *events = [self fetchEventsFromDate:monthData[@"startDate"] toDate:monthData[@"endDate"] withMOC:moc];
                        if(events) {
                            NSDictionary *monthStats = [[IMEventController sharedInstance] statisticsForEvents:events fromDate:monthData[@"startDate"] toDate:monthData[@"endDate"]];
                            
                            data = [data stringByAppendingFormat:@"\n\"%@\"", month];

                            if (exportActivity) {
                                data = [data stringByAppendingFormat:@",\"%@\"", [valueFormatter stringFromNumber:[monthStats objectForKey:kTotalMinutesKey]]];
                            }

                            if (exportMeal) {
                                data = [data stringByAppendingFormat:@",\"%@\"", [valueFormatter stringFromNumber:[monthStats objectForKey:kTotalGramsKey]]];
                            }
                            
                            if (exportGlucose) {
                                data = [data stringByAppendingFormat:@",\"%@\",\"%@\",\"%@\",\"%@\"", [glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingsAverageKey]], [glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingLowestKey]], [glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingHighestKey]], [glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingsDeviationKey]]];
                            }

                            if (exportCholesterol) {
                                data = [data stringByAppendingFormat:@",\"%@\",\"%@\",\"%@\",\"%@\"", [cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingsAverageKey]], [cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingLowestKey]], [cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingHighestKey]], [cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingsDeviationKey]]];
                            }
                            
                            if (exportWeight) {
                                data = [data stringByAppendingFormat:@",\"%@\",\"%@\"", [valueFormatter stringFromNumber:[monthStats objectForKey:kWtReadingLowestKey]], [valueFormatter stringFromNumber:[monthStats objectForKey:kWtReadingHighestKey]]];
                            }

                            if (exportBP) {
                                data = [data stringByAppendingFormat:@",\"%@\",\"%@\"", [valueFormatter stringFromNumber:[monthStats objectForKey:kBPReadingLowestKey]], [valueFormatter stringFromNumber:[monthStats objectForKey:kBPReadingHighestKey]]];
                            }
                        }
                    }
                }
            }

            data = [data stringByAppendingFormat:@"\n\nDate,Time,Type,Info,Value,Unit,Notes"];
            for(NSString *month in [reportData reverseKeyEnumerator]) {
                @autoreleasepool {
                    if([[selectedMonths objectForKey:month] boolValue]) {
                        NSDictionary *monthData = [reportData objectForKey:month];
                        NSArray *events = [self fetchEventsFromDate:monthData[@"startDate"] toDate:monthData[@"endDate"] withMOC:moc];
                        if(events) {
                            for(IMEvent *event in events) {
                                NSString *notes = event.notes ? [event.notes escapedForCSV] : @"";
                                NSString *name = [event.name escapedForCSV];
                                
                                NSString *time = [timeFormatter stringFromDate:event.timestamp];
                                NSString *date = [dateFormatter stringFromDate:event.timestamp];
                                if([event isKindOfClass:[IMNote class]]) {
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,,,%@", date, time, [event humanReadableName], name, notes];
                                } else if(exportMeal && [event isKindOfClass:[IMMeal class]]) {
                                    IMMeal *meal = (IMMeal *)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:meal.grams];
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,\"%@\",%@,%@", date, time, [event humanReadableName], name, value, [NSLocalizedString(@"Grams", @"Unit of measurement") lowercaseString], notes];
                                } else if(exportActivity && [event isKindOfClass:[IMActivity class]]) {
                                    IMActivity *activity = (IMActivity *)event;
                                    
                                    NSString *activityTime = [IMHelper formatMinutes:[activity.minutes integerValue]];
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,%@,%@,%@", date, time, [event humanReadableName], name, activityTime, NSLocalizedString(@"time", @"Unit of measurement"), notes];
                                } else if([event isKindOfClass:[IMMedicine class]]) {
                                    IMMedicine *medicine = (IMMedicine *)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:medicine.amount];
                                    NSString *unit = [[IMEventController sharedInstance] medicineTypeHR:[medicine.type integerValue]];
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,\"%@\",%@,%@", date, time, [event humanReadableName], name, value, unit, notes];
                                } else if(exportGlucose && [event isKindOfClass:[IMBGReading class]]) {
                                    IMBGReading *reading = (IMBGReading *)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:reading.value];
                                    NSString *unit = ([IMHelper userBGUnit] == BGTrackingUnitMG) ? @"mg/dL" : @"mmoI/L";
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,\"%@\",%@,%@", date, time, [event humanReadableName], name, value, unit, notes];
                                } else if (exportCholesterol && [event isKindOfClass:[IMCholesterolReading class]]) {
                                    IMCholesterolReading *reading = (IMCholesterolReading*)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:reading.value];
                                    NSString *unit = ([IMHelper userChUnit] == ChTrackingUnitMG) ? @"mg/dL" : @"mmoI/L";
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,\"%@\",%@,%@", date, time, [event humanReadableName], name, value, unit, notes];
                                } else if (exportWeight && [event isKindOfClass:[IMWeightReading class]]) {
                                    IMWeightReading *reading = (IMWeightReading*)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:reading.value];
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,\"%@\",%@,%@", date, time, [event humanReadableName], name, value, NSLocalizedString(@"kg", @"Unit of measurement"), notes];
                                } else if (exportBP && [event isKindOfClass:[IMBPReading class]]) {
                                    IMBPReading *reading = (IMBPReading*)event;
                                    
                                    NSString *value = [NSString stringWithFormat:@"Low:%@ High:%@",[valueFormatter stringFromNumber:reading.lowValue],[valueFormatter stringFromNumber:reading.highValue]];
                                    data = [data stringByAppendingFormat:@"\n\"%@\",%@,%@,%@,\"%@\",%@,%@", date, time, [event humanReadableName], name, value, NSLocalizedString(@"mm Hg", @"Unit of measurement"), notes];
                                }
                                
                                // Re-fault this object to conserve on memory
                                [moc refreshObject:event mergeChanges:NO];
                            }
                        }
                    }
                }
            }
            
            returnData = [data dataUsingEncoding:NSUTF8StringEncoding];
        }];
    }
    
    return returnData;
}

- (NSData *)generatePDFData {
    __block NSData *returnData = nil;
    
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] newPrivateContext];
    if(moc) {
        [moc performBlockAndWait:^{
            
            NSNumberFormatter *valueFormatter = [IMHelper standardNumberFormatter];
            NSNumberFormatter *glucoseFormatter = [IMHelper glucoseNumberFormatter];
            NSNumberFormatter *cholesterolFormatter = [IMHelper cholesterolNumberFormatter];
            
            IMPDFDocument *pdfDocument = [[IMPDFDocument alloc] init];
            [pdfDocument setDelegate:self];
            [pdfDocument drawText:[dateFormatter stringFromDate:[NSDate date]]
                           inRect:CGRectMake(pdfDocument.contentFrame.origin.x + pdfDocument.contentFrame.size.width - 100.0f, pdfDocument.contentFrame.origin.y, 100.0f, 16.0f)
                         withFont:[IMFont standardDemiBoldFontWithSize:12.0f]
                        alignment:NSTextAlignmentRight
                    lineBreakMode:NSLineBreakByClipping];
            
            [pdfDocument drawText:NSLocalizedString(@"HealthMemoir", nil) atPosition:pdfDocument.contentFrame.origin withFont:[IMFont standardBoldFontWithSize:20.0f]];
            
            [pdfDocument drawText:NSLocalizedString(@"Your Record", nil) atPosition:CGPointMake(pdfDocument.contentFrame.origin.x, pdfDocument.currentY + 30.0f) withFont:[IMFont standardDemiBoldFontWithSize:16.0f]];
            
            // Monthly breakdown
            [pdfDocument drawText:@"Monthly Breakdown" atPosition:CGPointMake(pdfDocument.contentFrame.origin.x, pdfDocument.currentY + 15.0f) withFont:[IMFont standardMediumFontWithSize:14.0f]];
            
            CGFloat columnWidth = ((pdfDocument.contentFrame.size.width/pdfDocument.contentFrame.size.width)*100)/7.0f;
            
            NSMutableArray* columns = [[NSMutableArray alloc] init];
            [columns addObject:@{@"title": @"Month", @"width": [NSNumber numberWithDouble:columnWidth]}];
            
            if (exportActivity) {
                [columns addObject:@{@"title": @"Total Activity", @"width": [NSNumber numberWithDouble:columnWidth]}];
            }
            
            if (exportMeal) {
                [columns addObject:@{@"title": @"Total Grams", @"width": [NSNumber numberWithDouble:columnWidth]}];
            }

            if (exportWeight) {
                [columns addObjectsFromArray:@[
                                               @{@"title": @"Weight (Lowest)", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Weight (Highest)", @"width": [NSNumber numberWithDouble:columnWidth]}
                                               ]];
            }
            
            if (exportBP) {
                [columns addObjectsFromArray:@[
                                               @{@"title": @"Blood Pressure (Lowest)", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Blood Pressure (Highest)", @"width": [NSNumber numberWithDouble:columnWidth]}
                                               ]];
            }

            if (exportGlucose) {
                [columns addObjectsFromArray:@[
                                               @{@"title": @"Glucose Avg.", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Glucose (Lowest)", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Glucose (Highest)", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Glucose Deviation", @"width": [NSNumber numberWithDouble:columnWidth]}
                                               ]];
            }

            if (exportCholesterol) {
                [columns addObjectsFromArray:@[
                                               @{@"title": @"Cholesterol Avg.", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Cholesterol (Lowest)", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Cholesterol (Highest)", @"width": [NSNumber numberWithDouble:columnWidth]},
                                               @{@"title": @"Cholesterol Deviation", @"width": [NSNumber numberWithDouble:columnWidth]}
                                               ]];
            }

            
            NSMutableArray *rows = [NSMutableArray array];
            for(NSString *month in [reportData reverseKeyEnumerator]) {
                @autoreleasepool {
                    NSDictionary *monthData = [reportData objectForKey:month];
                    if([[selectedMonths objectForKey:month] boolValue]) {
                        NSArray *events = [self fetchEventsFromDate:monthData[@"startDate"] toDate:monthData[@"endDate"] withMOC:moc];
                        if(events) {
                            NSDictionary *monthStats = [[IMEventController sharedInstance] statisticsForEvents:events fromDate:monthData[@"startDate"] toDate:monthData[@"endDate"]];
                            
                            NSMutableArray* objArray = [[NSMutableArray alloc] init];
                            [objArray addObject:month];
                            
                            if (exportActivity) {
                                [objArray addObject:[valueFormatter stringFromNumber:[monthStats objectForKey:kTotalMinutesKey]]];
                            }

                            if (exportMeal) {
                                [objArray addObject:[valueFormatter stringFromNumber:[monthStats objectForKey:kTotalGramsKey]]];
                            }

                            if (exportWeight) {
                                [objArray addObjectsFromArray:@[[valueFormatter stringFromNumber:[monthStats objectForKey:kWtReadingLowestKey]], [valueFormatter stringFromNumber:[monthStats objectForKey:kWtReadingHighestKey]]]];
                            }
                            
                            if (exportBP) {
                                [objArray addObjectsFromArray:@[[valueFormatter stringFromNumber:[monthStats objectForKey:kBPReadingLowestKey]], [valueFormatter stringFromNumber:[monthStats objectForKey:kBPReadingHighestKey]]]];
                            }

                            if (exportGlucose) {
                                [objArray addObjectsFromArray:@[[glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingsAverageKey]], [glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingLowestKey]], [glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingHighestKey]], [glucoseFormatter stringFromNumber:[monthStats objectForKey:kBGReadingsDeviationKey]]]];
                            }

                            if (exportCholesterol) {
                                [objArray addObjectsFromArray:@[[cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingsAverageKey]], [cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingLowestKey]], [cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingHighestKey]], [cholesterolFormatter stringFromNumber:[monthStats objectForKey:kChReadingsDeviationKey]]]];
                            }
                            
                            [rows addObject:objArray];
                        }
                    }
                }
            }

            [pdfDocument drawTableWithRows:rows
                                andColumns:columns
                                atPosition:CGPointMake(pdfDocument.contentFrame.origin.x, pdfDocument.currentY + 10.0f)
                                     width:pdfDocument.contentFrame.size.width
                                identifier:@"summary"];
            
            // Item entries
            [pdfDocument drawText:@"Itemised entries" atPosition:CGPointMake(pdfDocument.contentFrame.origin.x, pdfDocument.currentY + 25.0f) withFont:[IMFont standardMediumFontWithSize:14.0f]];
            
            columnWidth = ((pdfDocument.contentFrame.size.width/pdfDocument.contentFrame.size.width)*100)/5.0f;
            columns = [NSMutableArray arrayWithArray:@[
                                                       @{@"title": @"Date/Time", @"width": [NSNumber numberWithDouble:columnWidth]},
                                                       @{@"title": @"Type", @"width": [NSNumber numberWithDouble:columnWidth]},
                                                       @{@"title": @"Info", @"width": [NSNumber numberWithDouble:columnWidth]},
                                                       @{@"title": @"Value", @"width": [NSNumber numberWithDouble:columnWidth]},
                                                       @{@"title": @"Notes", @"width": [NSNumber numberWithDouble:columnWidth]}
                                                       ]];
            
            rows = [NSMutableArray array];
            for(NSString *month in [reportData reverseKeyEnumerator]) {
                @autoreleasepool {
                    
                    if([[selectedMonths objectForKey:month] boolValue]) {
                        NSDictionary *monthData = [reportData objectForKey:month];
                    
                        NSArray *events = [self fetchEventsFromDate:monthData[@"startDate"] toDate:monthData[@"endDate"] withMOC:moc];
                        if(events) {
                            for(IMEvent *event in events) {
                                NSString *notes = event.notes ? event.notes : @"";
                                NSString *name = event.name;
                                
                                NSString *time = [timeFormatter stringFromDate:event.timestamp];
                                NSString *date = [dateFormatter stringFromDate:event.timestamp];
                                if([event isKindOfClass:[IMNote class]]) {
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, @"", notes]];
                                } else if([event isKindOfClass:[IMMeal class]]) {
                                    IMMeal *meal = (IMMeal *)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:meal.grams];
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, [NSString stringWithFormat:@"%@ gm", value], notes]];
                                } else if([event isKindOfClass:[IMActivity class]]) {
                                    IMActivity *activity = (IMActivity *)event;
                                    
                                    NSString *activityTime = [valueFormatter stringFromNumber:activity.minutes];
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, [NSString stringWithFormat:@"%@ min", activityTime], notes]];
                                } else if([event isKindOfClass:[IMMedicine class]]) {
                                    IMMedicine *medicine = (IMMedicine *)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:medicine.amount];
                                    NSString *unit = [[IMEventController sharedInstance] medicineTypeHR:[medicine.type integerValue]];
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, [NSString stringWithFormat:@"%@ %@", value, unit], notes]];
                                } else if([event isKindOfClass:[IMBGReading class]]) {
                                    IMBGReading *reading = (IMBGReading *)event;
                                    
                                    NSString *value = [valueFormatter stringFromNumber:reading.value];
                                    NSString *unit = ([IMHelper userBGUnit] == BGTrackingUnitMG) ? @"mg/dL" : @"mmoI/L";
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, [NSString stringWithFormat:@"%@ %@", value, unit], notes]];
                                } else if ([event isKindOfClass:[IMCholesterolReading class]]) {
                                    IMCholesterolReading *reading = (IMCholesterolReading*)event;
                                    NSString *value = [valueFormatter stringFromNumber:reading.value];
                                    NSString *unit = ([IMHelper userChUnit] == ChTrackingUnitMG) ? @"mg/dL" : @"mmoI/L";
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, [NSString stringWithFormat:@"%@ %@", value, unit], notes]];
                                } else if ([event isKindOfClass:[IMWeightReading class]]) {
                                    IMWeightReading *reading = (IMWeightReading*)event;
                                    NSString *value = [valueFormatter stringFromNumber:reading.value];
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, [NSString stringWithFormat:@"%@ kg", value], notes]];
                                } else if ([event isKindOfClass:[IMBPReading class]]) {
                                    IMBPReading *reading = (IMBPReading*)event;
                                    NSString *lowValue = [valueFormatter stringFromNumber:reading.lowValue];
                                    NSString *highValue = [valueFormatter stringFromNumber:reading.highValue];
                                    [rows addObject:@[[NSString stringWithFormat:@"%@\n%@", date, time], [event humanReadableName], name, [NSString stringWithFormat:@"High:%@ mm Hg\nLow:%@ mm Hg", highValue, lowValue], notes]];
                                }
                                
                                // Re-fault this object to conserve on memory
                                [moc refreshObject:event mergeChanges:NO];
                            }
                        }
                    }
                }
            }
            
            [pdfDocument drawTableWithRows:rows
                                andColumns:columns
                                atPosition:CGPointMake(pdfDocument.contentFrame.origin.x, pdfDocument.currentY + 10.0f)
                                     width:pdfDocument.contentFrame.size.width
                                identifier:@"itemised"];
            
            [pdfDocument close];
            
            returnData = pdfDocument.data;
        }];
    }
    
    return returnData;
}

#pragma mark - IMPDFDocumentDelegate methods
- (void)drawPDFTableHeaderInDocument:(IMPDFDocument *)document
                      withIdentifier:(NSString *)identifier
                             content:(id)content
                   contentAttributes:(NSDictionary *)contentAttributes
                         contentRect:(CGRect)contentRect
                            cellRect:(CGRect)cellRect {
    [[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f] setFill];
    UIRectFill(cellRect);
    
    [[UIColor blackColor] setFill];
    [document drawText:(NSString *)content
                inRect:contentRect
              withFont:contentAttributes[IMPDFDocumentFontName]
             alignment:NSTextAlignmentLeft
         lineBreakMode:NSLineBreakByWordWrapping];
}

- (void)drawPDFTableCellInDocument:(IMPDFDocument *)document
                    withIdentifier:(NSString *)identifier
                           content:(id)content
                 contentAttributes:(NSDictionary *)contentAttributes
                       contentRect:(CGRect)contentRect
                          cellRect:(CGRect)cellRect
                      cellPosition:(CGPoint)cellPosition {
    if((int)cellPosition.y%2) {
        [[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f] setFill];
        UIRectFill(cellRect);
    }
    
    [[UIColor blackColor] setFill];
    [document drawText:(NSString *)content
                inRect:contentRect
              withFont:contentAttributes[IMPDFDocumentFontName]
             alignment:(cellPosition.x == 0 || [identifier isEqualToString:@"itemised"] ? NSTextAlignmentLeft : NSTextAlignmentCenter)
         lineBreakMode:NSLineBreakByWordWrapping];
}

- (NSDictionary *)attributesForPDFCellInDocument:(IMPDFDocument *)document
                                  withIdentifier:(NSString *)identifier
                                        rowIndex:(NSInteger)rowIndex
                                     columnIndex:(NSInteger)columnIndex {
    UIFont *font = [IMFont standardRegularFontWithSize:12.0f];
    if(rowIndex == 0) {
        font = [IMFont standardDemiBoldFontWithSize:12.0f];
    }
    
    return @{IMPDFDocumentFontName:font};
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [reportData count];
    }
    
    if (section == 2) {
        return 6;
    }
    
    return 2;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(@"Months to export", nil);
    } else if(section == 1) {
        return NSLocalizedString(@"Formats to export", nil);
    } else if(section == 2) {
        return NSLocalizedString(@"Things to export", nil);
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    IMGenericTableHeaderView *header = [[IMGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMGenericTableViewCell *cell = (IMGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"IMSettingCell"];
    if (cell == nil) {
        cell = [[IMGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IMSettingCell"];
    }
    
    if(indexPath.section == 0) {
        NSArray *keys = [reportData allKeys];
        NSString *date = [keys objectAtIndex:indexPath.row];
        
        cell.textLabel.text = date;
        
        if([[selectedMonths objectForKey:date] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"PDF";
            cell.accessoryType = exportPDF ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else {
            cell.textLabel.text = @"CSV";
            cell.accessoryType = exportCSV ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    } else if(indexPath.section == 2) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Activity";
            cell.accessoryType = exportActivity ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"Meal";
            cell.accessoryType = exportMeal ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else if(indexPath.row == 2) {
            cell.textLabel.text = @"Glucose";
            cell.accessoryType = exportGlucose ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else if(indexPath.row == 3) {
            cell.textLabel.text = @"Blood Pressure";
            cell.accessoryType = exportBP ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else if(indexPath.row == 4) {
            cell.textLabel.text = @"Cholesterol";
            cell.accessoryType = exportCholesterol ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else if(indexPath.row == 5) {
            cell.textLabel.text = @"Weight";
            cell.accessoryType = exportWeight ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }

    
    return cell;
}

#pragma mar - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0) {
        NSArray *keys = [reportData allKeys];
        NSString *date = [keys objectAtIndex:indexPath.row];
        
        BOOL selected = [[selectedMonths valueForKey:date] boolValue];
        [selectedMonths setValue:[NSNumber numberWithBool:!selected] forKey:date];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) exportPDF = !exportPDF;
        if(indexPath.row == 1) exportCSV = !exportCSV;
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if(indexPath.section == 2) {
        if(indexPath.row == 0) exportActivity = !exportActivity;
        if(indexPath.row == 1) exportMeal = !exportMeal;
        if(indexPath.row == 2) exportGlucose = !exportGlucose;
        if(indexPath.row == 3) exportBP = !exportBP;
        if(indexPath.row == 4) exportCholesterol = !exportCholesterol;
        if(indexPath.row == 5) exportWeight = !exportWeight;
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex <= 2) {
        [self triggerExport:buttonIndex];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if(result == MFMailComposeResultSent) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email sent", nil)
                                                            message:NSLocalizedString(@"Your export email has been sent", @"A success message letting the user know that their data export has been successfully emailed to them")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if(result == MFMailComposeResultFailed) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"Your export email could not be sent", @"An error message letting the user know that their data export could not be emailed to them")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    if(result != MFMailComposeResultFailed) {
        [controller dismissViewControllerAnimated:YES completion:^{
            // STUB
        }];
    }
}

#pragma mark - UIPrintInteractionControllerDelegate methods
- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController {
    return self.navigationController;
}

- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
