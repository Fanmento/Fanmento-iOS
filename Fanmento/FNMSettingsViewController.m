//
//  FNMSettingsViewController.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/29/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMSettingsViewController.h"

#import "Constant.h"
#import "FNMAppDelegate.h"
#import "HttpUserCredentials.h"
#import "SCFacebook.h"

@interface FNMSettingsViewController ()

@end

@implementation FNMSettingsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Email and Delegate

- (IBAction)showFeedbackForm:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        NSString *subjectString = [NSString stringWithFormat:@"FanMento App %@ Feedback", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [controller setSubject:subjectString];
        [controller setToRecipients:[NSArray arrayWithObject:@"feedback@fanmento.com"]];
        controller.mailComposeDelegate = self;

        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)termsAndConditions:(id)sender
{
    [[[FNMAlertView alloc] initWithTitle:@"Terms And Conditions" message:TERMS_OF_SERVICE delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil]show];
}

- (IBAction)privacyPolicy:(id)sender
{
    [[[FNMAlertView alloc] initWithTitle:@"Privacy Policy" message:PRIVACY_POLICY delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil]show];
}

- (IBAction)locationCodeButtonTouched:(id)sender
{
    self.tabBarController.selectedIndex = 1;
    [[FNMAppDelegate appDelegate].galleryViewController captureLocationCode];
}

- (IBAction)logOut:(id)sender
{
    // Remove user credentials
    [HttpUserCredentials signOutCurrentUser];
    [SCFacebook logoutCallBack:^(BOOL success, id result) {
        // Do nothing. This is safe to call even if the user didn't log in with Facebook
    }];

    // Reset user defaults
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Remove core data objects
    [[VICoreDataManager getInstance] resetCoreData];

    // Display login UI
    [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Logout"];
    [[[FNMAppDelegate appDelegate] viewController] dismissViewControllerAnimated:YES completion:^{
        [[FNMAppDelegate appDelegate] teardownTabBarController];
    }];
}

@end
