//
//  IMLoginViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 23/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMLoginViewController.h"
#import "IMUserViewController.h"
#import "IMRootViewController.h"
#import "IMUser.h"

@interface IMLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *relationTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation IMLoginViewController

@synthesize pageIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.hidden = YES;
    self.nameTextField.delegate = self;
    self.relationTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)saveUser:(id)sender {
    NSString* name = self.nameTextField.text;

    if ([name isEqualToString:@""]) {
        self.errorLabel.text = @"Must not be blank";
        self.errorLabel.hidden = NO;
        return;
    }
    
    NSString* relation = self.relationTextField.text;
    
    IMCoreDataStack *coreDataStack = [IMCoreDataStack defaultStack];
    IMUser *entry = [NSEntityDescription insertNewObjectForEntityForName:@"IMUser" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    entry.name = name;
    entry.relationship = relation;
    
    [coreDataStack saveContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"IMUser" inManagedObjectContext:coreDataStack.managedObjectContext];
    [fetchRequest setEntity:entityDesc];
    
    NSError *error = nil;
    NSArray *users = [coreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (users != nil && [users count] > 0) {
        IMUser* user = [users objectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setValue:user.guid forKey:kCurrentProfileKey];
    }

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IMRootViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"rootController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    return YES;
}

@end