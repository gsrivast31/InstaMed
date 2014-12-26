//
//  IMAvgBloodGlucoseChartViewController.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 22/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMChartViewController.h"

#import "IMEvent.h"
#import "IMBGReading.h"
#import "IMMeal.h"

@interface IMAvgBloodGlucoseChartViewController : IMChartViewController <SChartDatasource, SChartDelegate>
@end
