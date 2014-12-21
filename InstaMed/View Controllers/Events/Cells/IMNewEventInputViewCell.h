//
//  IMNewEventInputViewCell.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMEventInputField.h"

@interface IMNewEventInputViewCell : UITableViewCell <IMEventInputFieldProtocol>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;

@end
