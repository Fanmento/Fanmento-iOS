//
//  FNMRegisterViewController.m
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//
#import "FNMWelcomeViewController.h"
#import "FNMRegisterViewController.h"
#import "FNMLoginViewController.h"
#import "FNMAppDelegate.h"
#import "Constant.h"

#import "FNMAPI_User.h"

@interface FNMRegisterViewController ()

@property(nonatomic, strong) MBProgressHUD* hud;

@property(nonatomic, weak) IBOutlet UITextField *passwordConfirm;
@property(nonatomic, weak) IBOutlet UITextField *password;
@property(nonatomic, weak) IBOutlet UITextField *email;
@property(nonatomic, weak) IBOutlet UIButton *registerBtn;
@property(nonatomic, weak) IBOutlet UIImageView *bg;

@property (nonatomic, assign) id passChangedNotificationObserver;
@property (nonatomic, assign) id passConfirmChangedNotificationObserver;
@property (nonatomic, assign) id emailChangedNotificationObserver;

@end

@implementation FNMRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (isPhoneFive()) {
        [self.bg setImage:[UIImage imageNamed:@"bg_sign_up_phone5"]];
    }

    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    UIColor *color = [UIColor whiteColor];
    _email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    _password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    _passwordConfirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password Confirmation" attributes:@{NSForegroundColorAttributeName: color}];
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
    [self.passwordConfirm setText:@""];

    [self removeNoteObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)showLoginView:(id)sender
{
    [self.view endEditing:YES];
    if ([self.presentingViewController isKindOfClass:[FNMWelcomeViewController class]]) {
        FNMLoginViewController*login = [[FNMLoginViewController alloc] initWithNibName:@"FNMLoginViewController" bundle:nil];
        [login setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:login animated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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

- (IBAction)attemptRegister:(id)sender
{
    if ([self validateEmail] && [self validateMatchingPasswords]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            [self.hud setLabelText:@"Loading..."];
            [self.hud show:YES];
            [sender setUserInteractionEnabled:NO];
        });

        [FNMAPI_User registerForEmail:self.email.text
                             password:self.password.text
                                 name:nil
                                token:nil
                           completion:^(BOOL success, id object, NSInteger statusCode) {
                               [sender setUserInteractionEnabled:YES];
                               [self.hud hide:YES];

                               if (success) {
                                   [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Normal Register"];

                                   [self presentTabBarController];
                               } else {
                                   if (statusCode == 409) {
                                       [[[FNMAlertView alloc] initWithTitle:@"Already Registered"
                                                                    message:@"This email address has been registered. "\
                                                                            "Please select a different email address and try again."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Try Again"
                                                          otherButtonTitles:nil] show];
                                   } else {
                                       [[[FNMAlertView alloc] initWithTitle:@"Registration Error"
                                                                    message:@"There was an error with your registration"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Try Again"
                                                          otherButtonTitles:nil] show];
                                   }
                               }
                           }];
    }
}

- (IBAction)showFacebookLoginView:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
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

#pragma mark Notifications

- (void)setupNotifications
{
    self.passChangedNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                                                             object:self.password
                                                                                              queue:[NSOperationQueue mainQueue]
                                                                                         usingBlock:^(NSNotification *note) {
                                                                                             self.registerBtn.enabled = [self shouldEnableRegister];
                                                                                         }];

    self.emailChangedNotificationObserver =  [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                                                               object:self.email
                                                                                                queue:[NSOperationQueue mainQueue]
                                                                                           usingBlock:^(NSNotification *note) {
                                                                                               self.registerBtn.enabled = [self shouldEnableRegister];
                                                                                           }];

    self.passConfirmChangedNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                                                                    object:self.passwordConfirm
                                                                                                     queue:[NSOperationQueue mainQueue]
                                                                                                usingBlock:^(NSNotification *note) {
                                                                                                    self.registerBtn.enabled = [self shouldEnableRegister];
                                                                                                }];
}

- (void)removeNoteObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.passChangedNotificationObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.emailChangedNotificationObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.passConfirmChangedNotificationObserver];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)validateEmail
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_VALID_EMAIL
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.email.text
                                                        options:0
                                                          range:NSMakeRange(0, [self.email.text length])];

    if (numberOfMatches>0) {
        return TRUE;
    } else {
        [[[FNMAlertView alloc] initWithTitle:@"Invalid Email"
                                     message:@"Please enter a valid email address."
                                    delegate:nil
                           cancelButtonTitle:@"Try Again"
                           otherButtonTitles:nil] show];

        return FALSE;
    }
}

- (BOOL)validateMatchingPasswords
{
    if ([self.password.text isEqualToString:self.passwordConfirm.text]) {
        return TRUE;
    } else {
        [[[FNMAlertView alloc]initWithTitle:@"Passwords Incorrect"
                                    message:@"Your passwords do not match. Please re-enter your password and try again."
                                   delegate:nil
                          cancelButtonTitle:@"Try Again"
                          otherButtonTitles:nil] show];

        return FALSE;
    }
}

- (bool)shouldEnableRegister
{
    return (self.email.text.length > 0 &&
            self.password.text.length >= MIN_PASS_LENGTH &&
            self.password.text.length < MAX_PASS_LENGTH &&
            self.passwordConfirm.text.length >= MIN_PASS_LENGTH &&
            self.passwordConfirm.text.length < MAX_PASS_LENGTH);
}

@end
