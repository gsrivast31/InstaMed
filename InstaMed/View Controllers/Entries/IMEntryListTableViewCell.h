//
//  IMEntryListTableViewCell.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 19/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMCommon.h"

@interface IMEntryListTableViewCell : UITableViewCell

- (void) configureCellForEventType:(enum IMEventType)eventType eventName:(NSString*)name;

@end
