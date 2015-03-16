//
//  IMExportViewController.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 01/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>

#import "IMBaseViewController.h"
#import "OrderedDictionary.h"
#import "IMPDFDocument.h"

@interface IMExportViewController : IMBaseTableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, IMPDFDocumentDelegate>

- (void)refreshView;

// UI
- (void)performExport:(id)sender;
- (OrderedDictionary *)fetchEvents;

// Export
- (NSData *)generateCSVData;
- (NSData *)generatePDFData;

@end
