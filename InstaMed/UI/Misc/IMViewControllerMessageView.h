//
//  IMViewControllerMessageView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 05/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMViewControllerMessageView : UIView
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;

// Setup
+ (id)addToViewController:(UIViewController *)vc withTitle:(NSString *)title andMessage:(NSString *)message;
- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andMessage:(NSString *)message;

@end
