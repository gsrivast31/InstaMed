//
//  IMIntroViewController.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 04/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMIntroViewController.h"
#import "EAIntroView.h"

#import "IMRootViewController.h"
#import "IMLoginView.h"
#import "IMUser.h"

@interface IMIntroViewController () <EAIntroDelegate, UITextFieldDelegate>

@property (nonatomic, strong) EAIntroView* intro;

@end

@implementation IMIntroViewController

@synthesize intro;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Journal";
    page1.desc = @"HealthMemoir is a new kind of diabetic journal that lets you track your blood glucose, medication, food and personal activities.\n\nTo learn more swipe your finger to the left.";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"Export";
    page2.desc = @"HealthMemoir is capable of exporting your data in CSV or PDF format.\n\nPerfect for importing into other software or for printing to show your health care provider!";
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Reminders";
    page3.desc = @"Reminders are a great way to keep on top of things.\n\nAlong with one-time and repeat reminders you can also setup location-based reminders to alert you when you leave or arrive at a particular location.";
    
    page3.bgImage = [UIImage imageNamed:@"bg4"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
    
    EAIntroPage *page4 = [EAIntroPage pageWithCustomViewFromNibNamed:@"LoginView"];
    [self setDefaultState:(IMLoginView *)page4.customView];
    
    intro = [[EAIntroView alloc] initWithFrame:self.view.bounds];
    intro.skipButton.hidden = YES;
    [intro setDelegate:self];
    [intro setSwipeToExit:FALSE];
    [intro setTapToNext:TRUE];

    page4.onPageDidAppear = ^{
        [UIView animateWithDuration:0.1f animations:^{
            intro.pageControl.alpha = 0.0f;
        }];
    };
    page4.onPageDidDisappear = ^{
        [UIView animateWithDuration:0.1f animations:^{
            intro.pageControl.alpha = 1.0f;
        }];
    };
    
    [intro setPages:@[page1,page2,page3,page4]];
    [intro setDelegate:self];
    
    [intro showInView:self.view animateDuration:0.3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setDefaultState:(IMLoginView*)view {
    view.errorLabel.hidden = YES;
    view.nameTextField.delegate = self;
    view.relationTextField.delegate = self;
    
    [view.diabetesSwitch setOn:NO];
    [view.hyperTensionSwitch setOn:NO];
    [view.cholesterolSwitch setOn:NO];
    [view.weightSwitch setOn:NO];
    
    [view.restartIntroButton addTarget:self action:@selector(restartIntro:) forControlEvents:UIControlEventTouchUpInside];
    [view.createProfileButton addTarget:self action:@selector(saveUser:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)saveUser:(id)sender {
    EAIntroPage* page = (EAIntroPage*)[[intro pages] lastObject];
    IMLoginView* loginView = (IMLoginView*)page.customView;
    
    NSString* name = loginView.nameTextField.text;
    
    if ([name isEqualToString:@""]) {
        loginView.errorLabel.text = @"Must not be blank";
        loginView.errorLabel.hidden = NO;
        return;
    }
    
    NSString* relation = loginView.relationTextField.text;
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    IMUser *entry = [NSEntityDescription insertNewObjectForEntityForName:@"IMUser" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    entry.name = name;
    entry.relationship = relation;
    entry.trackingDiabetes = [loginView.diabetesSwitch isOn];
    entry.trackingHyperTension = [loginView.hyperTensionSwitch isOn];
    entry.trackingCholesterol = [loginView.cholesterolSwitch isOn];
    entry.trackingWeight = [loginView.weightSwitch isOn];
    entry.profilePhoto = UIImageJPEGRepresentation([UIImage imageNamed:@"icn_male"], 0.75);
    
    [coreDataStack saveContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"IMUser" inManagedObjectContext:coreDataStack.managedObjectContext];
    [fetchRequest setEntity:entityDesc];
    
    NSError *error = nil;
    NSArray *users = [coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (users != nil && [users count] > 0) {
        IMUser* user = [users objectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setValue:user.guid forKey:kCurrentProfileKey];
        [[NSUserDefaults standardUserDefaults] setValue:user.name forKey:kCurrentProfileName];
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingDiabetes forKey:kCurrentProfileTrackingDiabetesKey];
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingHyperTension forKey:kCurrentProfileTrackingBPKey];
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingCholesterol forKey:kCurrentProfileTrackingCholesterolKey];
        [[NSUserDefaults standardUserDefaults] setBool:user.trackingWeight forKey:kCurrentProfileTrackingWeightKey];
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IMRootViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"rootController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)restartIntro:(id)sender {
    [intro setCurrentPageIndex:0 animated:YES];
}

#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView {

}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    return YES;
}

@end
