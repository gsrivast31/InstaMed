//
//  IMEventViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMEvent.h"
#import "IMEventRepresentation.h"

#import "IMEventSectionHeaderView.h"

@interface IMEventViewController : IMBaseTableViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, IMEventRepresentationDelegate, IMEventRepresentationDataSource, IMEventSectionHeaderViewDelegate>

// Setup
- (id)initWithEvent:(IMEvent *)event;

@end
