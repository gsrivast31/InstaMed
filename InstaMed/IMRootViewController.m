//
//  IMRootViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 22/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMRootViewController.h"

#import "IMJournalTableViewController.h"
#import "IMJournalViewController.h"

#import "IMSideMenuViewController.h"
#import "IMAppDelegate.h"

@interface IMRootViewController ()

@end

@implementation IMRootViewController

- (void)awakeFromNib {
    IMJournalViewController *journalViewController = [[IMJournalViewController alloc] init];
    
    //UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //IMJournalTableViewController *journalViewController = [storyBoard instantiateViewControllerWithIdentifier:@"journalTableViewController"];
    
    IMNavigationController *navigationController = [[IMNavigationController alloc] initWithRootViewController:journalViewController];
    
    self.contentViewController = navigationController;
    self.menuViewController = [[IMSideMenuViewController alloc] init];
    
    self.direction = REFrostedViewControllerDirectionLeft;
    self.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    self.liveBlur = YES;
    self.limitMenuViewSize = YES;
    self.blurSaturationDeltaFactor = 3.0f;
    self.blurRadius = 10.0f;
    self.limitMenuViewSize = YES;
    
    CGFloat menuWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 340.0f : 280.0f;
    
    IMAppDelegate* appDelegate = (IMAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.menuViewSize = CGSizeMake(menuWidth, appDelegate.window.frame.size.height);
    appDelegate.viewController = self;
    //appDelegate.window.rootViewController = self;
}

@end
