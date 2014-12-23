//
//  IMPageViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 23/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMPageViewController.h"

@interface IMPageViewController ()

@end

@implementation IMPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)pageIdentifiers {
    return @[@"pageContentController", @"loginController"];
}

@end
