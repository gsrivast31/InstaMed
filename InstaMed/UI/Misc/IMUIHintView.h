//
//  IMUIHintView.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 12/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IMUIHintCallback)(void);

@interface IMUIHintView : UIView

// Setup
- (id)initWithFrame:(CGRect)frame text:(NSString *)text presentationCallback:(IMUIHintCallback)present dismissCallback:(IMUIHintCallback)dismiss;

// Logic
- (void)present;
- (void)dismiss;

@end
