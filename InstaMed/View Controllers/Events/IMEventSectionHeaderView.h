//
//  IMEventSectionHeaderView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 09/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMEventRepresentation.h"

@protocol IMEventSectionHeaderViewDelegate <NSObject>

- (void)headerDeleteButtonPressedForEventRepresentation:(IMEventRepresentation *)eventRepresentation;

@end

@interface IMEventSectionHeaderView : UITableViewHeaderFooterView
@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UIButton *deleteButton;

@property (nonatomic, weak) id<IMEventSectionHeaderViewDelegate> delegate;
@property (nonatomic, weak) IMEventRepresentation *eventRepresentation;

// Logic
- (IBAction)deleteButtonPressed:(id)sender;

@end
