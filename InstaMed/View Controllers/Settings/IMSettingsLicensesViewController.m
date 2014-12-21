//
//  IMSettingsLicensesViewController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 03/06/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMSettingsLicensesViewController.h"

@interface IMSettingsLicensesViewController ()
{
    UIWebView *webView;
}
@end

@implementation IMSettingsLicensesViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.title = NSLocalizedString(@"Licenses", nil);
    }
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    [baseView addSubview:webView];
    
    self.view = baseView;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    webView.frame = self.view.frame;
    
    NSString *licenseText = @"";
    NSArray *licenses = @[@"AFNetworking-License", @"AppSoundEngine-License", @"MBProgressHUD-License", @"HockeyApp-License", @"IMAppReviewManager-License", @"Reachability-License", @"FXBlurView-License", @"LXReorderableCollectionViewFlowLayout-License"];
    for(NSString *license in licenses)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:license ofType:@"txt"];
        if(bundlePath)
        {
            NSError *error = nil;
            NSString *contents = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:&error];
            if(!error)
            {
                licenseText = [licenseText stringByAppendingFormat:@"<h2>%@</h2>", [license stringByReplacingOccurrencesOfString:@"-License" withString:@""]];
                licenseText = [licenseText stringByAppendingFormat:@"<p>%@</p>", contents];
            }
        }
    }

    NSString *html = @"<html><head><style>body { font: 87.5% 'Avenir Next', 'Helvetica Neue', Arial, Helvetica, sans-serif; padding: 10px; color: #414141 } p { padding-bottom: 20px }</style></head><body style=\"background-color: transparent;\">";
    html = [html stringByAppendingString:[licenseText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"]];
    html = [html stringByAppendingString:@"</body></html>"];
    
    [webView loadHTMLString:html baseURL:nil];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    webView.frame = self.view.bounds;
    webView.scrollView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
    webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
}


@end
