//
//  IMReportAddEditViewController.h
//  HealthMemoir
//
//  Created by Ranjeet on 3/16/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMReport.h"

@interface IMReportAddEditViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@property (nonatomic) enum IMReportType reportType;
@property (nonatomic, strong) IMReport *entry;

@end
