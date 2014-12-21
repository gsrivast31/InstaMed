//
//  IMNavPageControl.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 26/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMInputParentViewController;
@interface IMNavPageControl : UIView
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) NSInteger currentPage;

// Helpers
- (NSString *)iconForPage:(NSInteger)page;

@end
