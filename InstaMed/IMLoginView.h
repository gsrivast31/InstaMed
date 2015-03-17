//
//  IMLoginView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMLoginView : UIView

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *relationTextField;
@property (weak, nonatomic) IBOutlet UISwitch *diabetesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hyperTensionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cholesterolSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *weightSwitch;
@property (weak, nonatomic) IBOutlet UIButton *restartIntroButton;
@property (weak, nonatomic) IBOutlet UIButton *createProfileButton;

@end
