//
//  FNMWelcomeViewController.m
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMWelcomeViewController.h"
#import "FNMLoginViewController.h"
#import "FNMRegisterViewController.h"
#import "SCFacebook.h"
#import "FNMAPI_User.h"
#import "FNMAppDelegate.h"
#import "HttpUserCredentials.h"
#import "Constant.h"

@interface FNMWelcomeViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *bg;
@property(nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FNMWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (isPhoneFive()) {
        [self.bg setImage:[UIImage imageNamed:@"bg_start_up_splash_logo_phone5"]];
    }
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    HttpUserCredentials *user = [HttpUserCredentials getCurrentUser];

    if ([user.username length] && [user.password length]) {
        [self presentTabBarController];
    }
}

- (IBAction)showLoginView:(id)sender
{
    FNMLoginViewController *login = [[FNMLoginViewController alloc] initWithNibName:nil bundle:nil];
    [login setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:login animated:YES completion:nil];
}

- (IBAction)showRegisterView:(id)sender
{
    FNMRegisterViewController *registerView = [[FNMRegisterViewController alloc] initWithNibName:nil bundle:nil];
    [registerView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:registerView animated:YES completion:nil];
}

- (IBAction)showFacebookLoginView:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud show:YES];
    });

    [FNMAPI_User registerViaFacebook:^(BOOL success, id result) {
        [self.hud hide:YES];

        if (success) {
            [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Facebook Register/Login"];

            [self presentTabBarController];
        } else {
            [[[FNMAlertView alloc]initWithTitle:@"Login Error"
                                        message:@"There was an error with your login."
                                       delegate:nil
                              cancelButtonTitle:@"Try Again"
                              otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)termsOfService:(id)sender
{
    [[[FNMAlertView alloc] initWithTitle:@"Terms And Conditions"
                                 message:TERMS_OF_SERVICE
                                delegate:nil
                       cancelButtonTitle:@"Close"
                       otherButtonTitles:nil] show];
}

- (void)presentTabBarController
{
    // Only present the tab bar controller if it is not already visible
    if([[FNMAppDelegate appDelegate] tabBarController].presentingViewController == nil) {
        [[FNMAppDelegate appDelegate] setupTabBarController];
        [self presentViewController:[[FNMAppDelegate appDelegate] tabBarController] animated:NO completion:^{
            DLog(@"WHAT?");
        }];
    }
}

@end
