//
//  IMAddEntryViewiPad.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 16/01/2014.
//  Copyright 2014 GAURAV SRIVASTAVA
//

#import "FXBlurView.h"
#import "IMAddEntryModalView.h"

@interface IMAddEntryiPadView : FXBlurView
@property (nonatomic, weak) id<IMAddEntryModalDelegate> delegate;

// Setup
+ (id)presentInView:(UIView *)parentView;

@end
