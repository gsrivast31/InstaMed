//
//  IMGlucoseLineChartViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 09/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMChartViewController.h"

#import "IMEvent.h"
#import "IMBGReading.h"

@class IMLineFitCalculator;
@interface IMGlucoseLineChartViewController : IMChartViewController <SChartDatasource, SChartDelegate>
@end
