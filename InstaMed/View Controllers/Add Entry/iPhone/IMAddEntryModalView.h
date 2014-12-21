//
//  IMAddEntryModalView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMAddEntryModalView;
@protocol IMAddEntryModalDelegate <NSObject>

- (void)addEntryModal:(id)modalView didSelectEntryOption:(NSInteger)buttonIndex;

@end

@interface IMAddEntryModalView : UIView
@property (weak, nonatomic) id<IMAddEntryModalDelegate> delegate;

// Logic
- (void)present;
- (void)dismiss;
@end
