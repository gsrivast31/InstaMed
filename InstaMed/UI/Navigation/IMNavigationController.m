//
//  IMNavigationController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 30/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMNavigationController.h"

@implementation IMNavigationController

#pragma mark - Setup
- (void)viewDidLoad
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
    
    // Setup a double tap gesture recogniser
    UITapGestureRecognizer *doubleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(didDoubleTapNavigationBar:)];
    doubleTapRecogniser.numberOfTapsRequired = 2;
    doubleTapRecogniser.delaysTouchesBegan = NO;
    doubleTapRecogniser.delaysTouchesEnded = NO;
    [self.navigationBar addGestureRecognizer:doubleTapRecogniser];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - UINavigationControllerDelegate
// A nasty hack found here: http://keighl.com/post/ios7-interactive-pop-gesture-custom-back-button/
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - Logic
- (void)didDoubleTapNavigationBar:(UIGestureRecognizer*)recognizer
{
    // STUB
}
- (NSUInteger)supportedInterfaceOrientations
{
    if([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return [self.topViewController supportedInterfaceOrientations];
    }
    
    return 0;
}
- (BOOL)shouldAutorotate
{
    if([self.topViewController respondsToSelector:@selector(shouldAutorotate)]) 
    {
        return [self.topViewController shouldAutorotate];
    }
    
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if([self.topViewController respondsToSelector:@selector(preferredStatusBarStyle)])
    {
        return [self.topViewController preferredStatusBarStyle];
    }
    
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    if([self.topViewController respondsToSelector:@selector(prefersStatusBarHidden)])
    {
        return [self.topViewController prefersStatusBarHidden];
    }
    
    return NO;
}

@end