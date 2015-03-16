//
//  IMKeyboardShortcutButton.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 31/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMKeyboardShortcutButton : UIButton
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIImageView *fullsizeImageView;

#pragma mark - Logic
- (void)showActivityIndicator:(BOOL)state;

@end
