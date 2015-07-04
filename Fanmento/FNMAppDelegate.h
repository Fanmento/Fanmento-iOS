//
//  FNMAppDelegate.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FNMGalleryViewController.h"
#import "FNMMyCollectionViewController.h"
#import "FNMSettingsViewController.h"
#import "FNMOrderPrintsViewController.h"
#import "FNMGalleryDetailViewController.h"
#import "FBConnect.h"

@interface FNMAppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, assign) Facebook *facebook;

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) UIViewController *viewController;

@property(assign, nonatomic) BOOL isFacebookLoginInProgress;

@property(strong, nonatomic) FNMMyCollectionViewController *myCollectionViewController;
@property(strong, nonatomic) FNMSettingsViewController *settingsViewController;
@property(strong, nonatomic) FNMOrderPrintsViewController *orderPrintsViewController;
@property(strong, nonatomic) FNMGalleryViewController* galleryViewController;

@property(strong, nonatomic) UITabBarController *tabBarController;
@property(assign, nonatomic) BOOL isOffline;

- (void)setupTabBarController;
- (void)teardownTabBarController;
- (NSURL *)applicationDocumentsDirectory;
+ (FNMAppDelegate *)appDelegate;
- (void)executeBlock:(void (^)(void))block;
- (void)trackPageViewWithName:(NSString *)pageView;

- (void)enableTabBar;
- (void)disableTabBar;

@end
