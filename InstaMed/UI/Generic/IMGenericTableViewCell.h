//
//  IMGenericTableViewCell.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 16/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    IMCellBackgroundViewPositionSingle = 0,
    IMCellBackgroundViewPositionTop,
    IMCellBackgroundViewPositionBottom,
    IMCellBackgroundViewPositionMiddle
} IMCellPosition;

@interface IMGenericTableViewCell : UITableViewCell
@property (nonatomic, assign) IMCellPosition cellPosition;
@property (nonatomic, retain) id accessoryControl;

// Logic
- (void)setCellStyleWithIndexPath:(NSIndexPath *)indexPath andTotalRows:(NSInteger)totalRows;

@end
