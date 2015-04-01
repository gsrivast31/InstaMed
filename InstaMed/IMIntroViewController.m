//
//  IMIntroViewController.m
//  InstaMed
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
    page1.title = @"";
    page1.desc = @"Keep track of blood glucose, hypertension, medicines, cholesterol, weight, food and personal activities.";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner1_small"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"";
    page2.desc = @"View your recorded data in a nicely arranged timeline.";
    page2.bgImage = [UIImage imageNamed:@"bg1"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner2_small"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"";
    page3.desc = @"Store all your  physical records including physician reports, drug prescriptions, lab results, hospital papers etc.";
    page3.bgImage = [UIImage imageNamed:@"bg1"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner3_small"]];

    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"";
    page4.desc = @"Manage separate records for yourself and your family members. Set their preferences and track the thing they want to track(Diabetes, Blood Pressure, Weight, Cholesterol).";
    page4.bgImage = [UIImage imageNamed:@"bg1"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner4_small"]];

    EAIntroPage *page5 = [EAIntroPage page];
    page5.title = @"";
    page5.desc = @"Analytics : See how you perform over a period; how much you deviate and what has been your average record.";
    page5.bgImage = [UIImage imageNamed:@"bg1"];
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner5_small"]];

    EAIntroPage *page6 = [EAIntroPage page];
    page6.title = @"";
    page6.desc = @"More : Set reminders, add tags to records for easy management, export them to pdf or csv etc.";
    page6.bgImage = [UIImage imageNamed:@"bg1"];
    page6.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner7_small"]];

    EAIntroPage *page7 = [EAIntroPage pageWithCustomViewFromNibNamed:@"LoginView"];
    [self setDefaultState:(IMLoginView *)page7.customView];
    
    intro = [[EAIntroView alloc] initWithFrame:self.view.bounds];
    intro.skipButton.hidden = YES;
    [intro setDelegate:self];
    [intro setSwipeToExit:FALSE];
    [intro setTapToNext:TRUE];

    page7.onPageDidAppear = ^{
        [UIView animateWithDuration:0.1f animations:^{
            intro.pageControl.alpha = 0.0f;
        }];
    };
    page7.onPageDidDisappear = ^{
        [UIView animateWithDuration:0.1f animations:^{
            intro.pageControl.alpha = 1.0f;
        }];
    };
    
    [intro setPages:@[page1,page2,page3,page4,page5,page6,page7]];
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
