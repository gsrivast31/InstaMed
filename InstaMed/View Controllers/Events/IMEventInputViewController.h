//
//  IMEventInputViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 11/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMBaseViewController.h"
#import "IMEvent.h"

@interface IMEventInputViewController : IMBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) IMEvent *event;

// Setup
- (id)initWithEventType:(NSInteger)eventType;
- (id)initWithEvent:(IMEvent *)aEvent;
- (id)initWithMedicineAmount:(NSNumber *)amount;

// UI
- (void)presentAddReminder:(id)sender;
- (void)presentMediaOptions:(id)sender;
- (void)presentGeotagOptions:(id)sender;
- (void)updateNavigationBar;

@end
