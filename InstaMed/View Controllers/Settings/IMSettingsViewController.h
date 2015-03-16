//
//  IMSettingsViewController.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 17/12/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "IMBaseViewController.h"
#import "IMRemindersViewController.h"
#import "IMMediaController.h"

@interface IMSettingsViewController : IMBaseTableViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@end
