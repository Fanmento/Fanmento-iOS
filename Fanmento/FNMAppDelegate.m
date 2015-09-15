//
//  FNMAppDelegate.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMAppDelegate.h"
#import "VICoreDataManager.h"
#import "UITabBarController+FNMTabBarController.h"
#import "FNMWelcomeViewController.h"
#import "RemoteNetworkUtility.h"
#import "NetworkUtility.h"
#import "SCFacebook.h"
#import "HttpUserCredentials.h"
#import "FNMFinalPictureRemover.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
//#import <BugSense-iOS/BugSenseController.h>

//#import "GANTracker.h"
#import "Constant.h"

#import "FNMAPI_Templates.h"
#import "FNMTemplate.h"
#import "APIConstants.h"

#define DATABASE_VERSION @"0.9"

// Dispatch period in seconds - google analytics
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation FNMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[VICoreDataManager getInstance] setResource:@"FNMModel" database:@"model.sqlite"];

    [SCFacebook initWithAppId:@"395199007202207"];
    [self versionTracking];
    [self setupGan];

    //setup version label in settings bundle
    NSString *version = [NSString stringWithFormat:@"%@ Build %@",
                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version_preference"];

    //bugsense
#ifndef DEBUG
//    [BugSenseController sharedControllerWithBugSenseAPIKey:BUG_SENSE_API_KEY
  //                                          userDictionary:@{BUG_SENSE_API_KEY: @"Fanmento-iOS"}
    //                                       sendImmediately:NO];
#endif

    [[NetworkUtility getInstance] setDelegate:[[RemoteNetworkUtility alloc] initWithAcceptsHeader:RemoteNetworkUtilityAcceptsJSON]];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    FNMWelcomeViewController *welcomeView = [[FNMWelcomeViewController alloc] initWithNibName:nil bundle:nil];
    self.viewController = welcomeView;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_URL object:url];
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_URL object:url];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.galleryViewController.displayLocationServicesAccessDeniedWarning = YES;

    if (self.isFacebookLoginInProgress) {
        [SCFacebook cancelLogin];
    }

    // Syncs My Collection with server and removes pictures on the device that were deleted by the admin server side
    [FNMFinalPictureRemover removeServerDeletedPictures];
}

- (void)versionTracking
{
    NSString *version = [NSString stringWithFormat:@"%@ Build %@",
                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version_preference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    //[[GANTracker sharedTracker] stopTracker];
}

+ (FNMAppDelegate *)appDelegate
{
    return (FNMAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)setupGan
{
    /*[[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-34286983-1"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];

    [[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                    name:@"iPhone1"
                                                   value:@"iv1"
                                               withError:nil];

    [[GANTracker sharedTracker] trackEvent:@"my_category"
                                    action:@"my_action"
                                     label:@"my_label"
                                     value:-1
                                 withError:nil];

    [self trackPageViewWithName:@"/app_entry_point"];*/
}

- (void)trackPageViewWithName:(NSString *)pageView
{
    //[[GANTracker sharedTracker] trackPageview:pageView withError:nil];
}

- (void)setupTabBarController
{
    UIViewController *dummyViewController = [[UIViewController alloc] init];

    self.myCollectionViewController.tabBarItem.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"my-collection" ofType:@"png"]];
    self.myCollectionViewController.tabBarItem.title = @"my collection";

    self.settingsViewController.tabBarItem.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings_gear" ofType:@"png"]];
    self.settingsViewController.tabBarItem.title = @"settings";

    self.orderPrintsViewController.tabBarItem.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shopping" ofType:@"png"]];
    self.orderPrintsViewController.tabBarItem.title = @"order prints";

    self.galleryViewController.tabBarItem.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"template_list" ofType:@"png"]];
    self.galleryViewController.tabBarItem.title = @"templates";

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.tabBar.backgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bottom_tab_bar_background" ofType:@"png"]];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tab-button_over-state" ofType:@"png"]];

    [self.tabBarController setViewControllers:@[self.myCollectionViewController,
                                                self.galleryViewController,
                                                dummyViewController,
                                                self.settingsViewController,
                                                self.orderPrintsViewController]];

    [self.tabBarController setSelectedViewController:self.galleryViewController];

    UITabBarItem *tabBarItem = [[self.tabBarController.tabBar items] objectAtIndex:2];
    [tabBarItem setEnabled:NO];

    [self.tabBarController addCenterButtonWithImage:[UIImage imageNamed:@"middle_finger_button"] highlightImage:nil];
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)teardownTabBarController
{
    self.myCollectionViewController = nil;
    self.settingsViewController = nil;
    self.orderPrintsViewController = nil;
    self.galleryViewController = nil;
    self.tabBarController = nil;
}

- (void)disableTabBar
{
    for (UITabBarItem *item in [self.tabBarController.tabBar items]) {
        [item setEnabled:NO];
    }
}

- (void)enableTabBar
{
    for (UITabBarItem *item in [self.tabBarController.tabBar items]) {
        if (![item isEqual:[self.tabBarController.tabBar.items objectAtIndex:2]]) {
            [item setEnabled:YES];
        }
    }
}

- (FNMGalleryViewController *)galleryViewController
{
    if(_galleryViewController == nil) {
        _galleryViewController = [[FNMGalleryViewController alloc] initWithNibName:nil bundle:nil];
    }

    return _galleryViewController;
}

- (FNMMyCollectionViewController *)myCollectionViewController
{
    if(_myCollectionViewController == nil) {
        _myCollectionViewController = [[FNMMyCollectionViewController alloc] initWithNibName:nil bundle:nil];
    }

    return _myCollectionViewController;
}

- (FNMOrderPrintsViewController *)orderPrintsViewController
{
    if(_orderPrintsViewController == nil) {
        _orderPrintsViewController = [[FNMOrderPrintsViewController alloc] initWithNibName:nil bundle:nil];
    }

    return _orderPrintsViewController;
}

- (FNMSettingsViewController *)settingsViewController
{
    if(_settingsViewController == nil) {
        _settingsViewController = [[FNMSettingsViewController alloc] initWithNibName:@"FNMSettingsViewController" bundle:nil];
    }

    return _settingsViewController;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DLog(@"Did Receive Memory Warning");
    [VILoaderImageView clearLocalCache];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)executeBlock:(void (^)(void))block
{
    [self performSelectorInBackground:@selector(executeBlockInBG:) withObject:block];
}

-(void)executeBlockInBG:(void (^)(void))block
{
    block();
}

#pragma mark Clear Core Data

-(void)deleteOldDatabaseCheck
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:DATABASE_VERSION]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DATABASE_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self deleteDatabase];
}

- (void)deleteDatabase
{
    // For error information
    NSError *error;
    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSArray *documentsArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory
                                                           error:nil];
    
    for (int i = 0; i < [documentsArray count]; i++) {
        if ([[[[documentsArray objectAtIndex:i]
               componentsSeparatedByString:@"."]
              lastObject]
             isEqualToString:@"sqlite"]) {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:
                              [documentsArray objectAtIndex:i]];
            [fileMgr removeItemAtPath:path error:&error];
        }
    }
    DLog(@"Documents directory: %@",[fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}

@end
