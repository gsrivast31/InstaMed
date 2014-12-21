//
//  IMEventRepresentation.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 08/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMTagController.h"

#import "IMEvent.h"

#import "IMNewEventInputViewCell.h"
#import "IMNewEventTextBlockViewCell.h"

@class IMEventRepresentation;
@protocol IMEventRepresentationDelegate <NSObject>
- (void)eventRepresentation:(IMEventRepresentation *)representation willSaveEvent:(IMEvent *)event;
@end

@protocol IMEventRepresentationDataSource <NSObject>
- (UITableView *)tableViewForEventRepresentation:(IMEventRepresentation *)representation;
@end

@interface IMEventRepresentation : NSObject <UITextViewDelegate>
{
    UITextView *dummyNotesTextView;
}
@property (nonatomic, weak) id<IMEventRepresentationDelegate> delegate;
@property (nonatomic, weak) id<IMEventRepresentationDataSource> dataSource;
@property (nonatomic, strong) IMEvent *event;

@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *notes;

@property (nonatomic, strong) IMNewEventTextBlockViewCell *notesViewCell;

// Setup
- (id)initWithEvent:(IMEvent *)theEvent;
- (void)commonInit;

// Logic
- (BOOL)saveEvent:(IMEvent **)event error:(NSError **)error;
- (BOOL)deleteEvent:(NSError **)error;
- (NSError *)validationError;
- (UITableViewCell *)cellForTableView:(UITableView *)tableView withFieldIndex:(NSUInteger)index;
- (CGFloat)heightForCellWithFieldIndex:(NSUInteger)index inTableView:(UITableView *)tableView;
- (NSUInteger)numberOfFields;

@end
