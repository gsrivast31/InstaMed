//
//  IMLeastSquareFitCalculator.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 06/05/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMLineFitCalculator : NSObject

// Logic
- (void)addPoint:(CGPoint)point;
- (CGFloat)projectedYValueForX:(CGFloat)x;
@end

@interface IMSquareFitCalculator : NSObject

// Logic
- (void)addPoint:(CGPoint)point;
- (CGFloat)projectedYValueForX:(CGFloat)x;
@end
