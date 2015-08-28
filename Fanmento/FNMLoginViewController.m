//
//  FNMLoginViewController.m
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMLoginViewController.h"
#import "FNMRegisterViewController.h"
#import "FNMAppDelegate.h"
#import "Constant.h"

#import "FNMAPI_User.h"

#import "HttpUserCredentials.h"
#import "FNMWelcomeViewController.h"
#import "MBProgressHUD.h"

@interface FNMLoginViewController ()

@property(nonatomic, weak) IBOutlet UITextField *password;
@property(nonatomic, weak) IBOutlet UITextField *email;
@property(nonatomic, weak) IBOutlet UIImageView *bg;

@property(nonatomic, weak) IBOutlet UIButton *loginBtn;

@property(nonatomic, strong) MBProgressHUD *hud;

@property(nonatomic, assign) id passChangedNotificationObserver;
@property(nonatomic, assign) id emailChangedNotificationObserver;
@end

@implementation FNMLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (isPhoneFive()) {
        [self.bg setImage:[UIImage imageNamed:@"bg_sign_up_phone5"]];
    }

    self.hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:self.hud];
    
    UIColor *color = [UIColor whiteColor];
    _email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    _password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setupNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.email setText:@""];
    [self.password setText:@""];
    [self removeNoteObservers];
}



#pragma mark Notifications
- (void)setupNotifications
{
    self.passChangedNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                                                             object:self.password
                                                                                              queue:[NSOperationQueue mainQueue]
                                                                                         usingBlock:^(NSNotification *note) {
                                                                                             self.loginBtn.enabled = [self shouldEnableLogin];
                                                                                         }];

    self.emailChangedNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                                                              object:self.email
                                                                                               queue:[NSOperationQueue mainQueue]
                                                                                          usingBlock:^(NSNotification *note) {
                                                                                              self.loginBtn.enabled = [self shouldEnableLogin];
                                                                                          }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)removeNoteObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.passChangedNotificationObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.emailChangedNotificationObserver];
}

- (bool)shouldEnableLogin
{
    return (self.email.text.length > 0 && self.password.text.length >= MIN_PASS_LENGTH);
}

#pragma mark Actions

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

- (IBAction)showRegisterView:(id)sender
{
    [self.view endEditing:YES];
    if ([self.presentingViewController isKindOfClass:[FNMWelcomeViewController class]]) {
        FNMRegisterViewController*registerView = [[FNMRegisterViewController alloc] initWithNibName:@"FNMRegisterViewController" bundle:nil];
        [registerView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:registerView animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)attemptLogin:(id)sender
{
    [self.view endEditing:YES];
    [self.hud setLabelText:@"Loading..."];
    [self.hud show:YES];
    [sender setUserInteractionEnabled:NO];

    HttpUserCredentials *user = [[HttpUserCredentials alloc] init];
    [user setPassword:self.password.text];
    [user setUsername:self.email.text];
    [HttpUserCredentials setCurrentUser:user];

    [FNMAPI_User loginWithCompletion:^(BOOL success, id object, NSInteger statusCode) {
        [sender setUserInteractionEnabled:YES];
        [self.hud hide:YES];

        if (success) {
            [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Login with Username"];

            [self presentTabBarController];
        } else {
            [HttpUserCredentials signOutCurrentUser];

            if (statusCode == 403 || statusCode == 401) {
                [[[FNMAlertView alloc] initWithTitle:@"Login Error"
                                             message:@"You entered an invalid email address or password. "\
                                                    "Please reenter your login credentials and try again."
                                            delegate:nil
                                   cancelButtonTitle:@"Try Again"
                                   otherButtonTitles:nil] show];
            } else {
                [[[FNMAlertView alloc] initWithTitle:@"Login Error"
                                             message:@"There was an error with your login."
                                            delegate:nil
                                   cancelButtonTitle:@"Try Again"
                                   otherButtonTitles:nil] show];
            }
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

- (IBAction)forgotPassword:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FORGOT_PASS_LINK]];
}

- (void)presentTabBarController
{
    [self.view endEditing:YES];
    // Only present the tab bar controller if it is not already visible
    if([[FNMAppDelegate appDelegate] tabBarController].presentingViewController == nil) {
        [[FNMAppDelegate appDelegate] setupTabBarController];
        [self presentViewController:[[FNMAppDelegate appDelegate] tabBarController] animated:YES completion:nil];
    }
}

@end
