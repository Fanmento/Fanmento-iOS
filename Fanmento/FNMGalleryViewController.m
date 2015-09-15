//
//  FNMGalleryViewController.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryViewController.h"
#import "FNMGalleryDetailViewController.h"
#import "FNMAppDelegate.h"
#import "FTAnimation.h"
#import "FNMAPI_Templates.h"
#import "VILoaderImageView.h"
#import "FNMTemplate.h"
#import "ODRefreshControl.h"
#import "UIImageView+WebCache.h"
#import "Constant.h"
#import "DEStoreKitManager.h"
#import "FNMAPI_Venue.h"
#import "FNMVenue.h"

#import <objc/runtime.h>

NSInteger const fnmAllToggleTag = 411;
NSInteger const fnmLocalToggleTag = 114;
NSInteger const fnmCategoryToggleTag = 42;
NSInteger const fnmVenueTitleTag = 117;

NSInteger const fnmRightPremiumCorner = 1234;
NSInteger const fnmLeftPremiumCorner = 4321;

static NSString *categoryNames[6] = {
    nil,
    @"Sports",
    @"Entertainment",
    @"Music",
    @"Lifestyle",
    @"Miscellaneous"
};

typedef enum {
    fnmUserLocation,
    fnmVenueLocation,
    fnmCode
} LocationSource;

@interface FNMGalleryViewController ()

@property (strong, nonatomic) FNMAppDelegate *appDelegate;

@property (strong, nonatomic) UIView *topBar;
@property (strong, nonatomic) UIButton *currentSelection;

@property (strong, nonatomic) UIImageView *emptyPlaceholder;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *templatesToDisplay;

@property (strong, nonatomic) UIView *categoryPicker;

@property (assign, nonatomic) BOOL codeOnly;
@property (strong, nonatomic) UIView *userInputLocationView;
@property (strong, nonatomic) UITextField *codeEntry;
@property (strong, nonatomic) UIButton *tryCode;

@property (strong, nonatomic) UIView *pickerView;
@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) UIToolbar *doneBar;
@property (strong, nonatomic) NSArray *possibleVenues;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (nonatomic) NSInteger rowCount;
@property (nonatomic) BOOL showingLocalTemplates;
@property (nonatomic) templateCategory currentCategory;

@property (nonatomic) NSInteger currentTemplatesWithoutVenuePage;
@property (nonatomic) NSInteger currentLocationPage;
@property (nonatomic) BOOL loadingMorePages;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) LocationSource currentLocationSource;
@property (nonatomic) BOOL loadingFirstPageOfLocationTemplates;
@property (strong, nonatomic) FNMVenue *currentVenue;
@property (strong, nonatomic) NSString *currentCode;

@property (nonatomic) id fingerTapObserver;

@end

@implementation FNMGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.codeOnly = NO;

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Fanmento_Grey_Background"]];
    [self.view addSubview:backgroundImageView];
    backgroundImageView.frame = CGRectMake(0,0,320,screenHeight()-30);

    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    [self.appDelegate.window addSubview:self.hud];

    self.templatesToDisplay = [[NSMutableArray alloc] init];

    [self setupTable];
    [self createToggleTemplatesBar];
    
    [self updateVenueNames];
    [self setupPullToRefresh];
    [self displayTemplatesWithoutVenue];

    self.displayLocationServicesAccessDeniedWarning = YES;

    self.fingerTapObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_FINGER_TAPPED
                                                                               object:nil
                                                                                queue:[NSOperationQueue mainQueue]
                                                                           usingBlock:^(NSNotification *note) {
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   self.codeOnly = NO;
                                                                                   [self showLocalTemplates:[self.view viewWithTag:fnmLocalToggleTag]];
                                                                               });
                                                                           }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self checkForOverlayShown];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (FNMAppDelegate *)appDelegate
{
    return [FNMAppDelegate appDelegate];
}

- (CLLocationManager *)locationManager
{
    if(!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }

    return _locationManager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.fingerTapObserver];
}

#pragma mark - Setup Toggle

- (void)createToggleTemplatesBar
{
    self.topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];

    UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    categoryButton.frame = CGRectMake(0, 0, 106, 36);
    categoryButton.tag = fnmCategoryToggleTag;
    [categoryButton setImage:[UIImage imageNamed:@"top_menu_CATEGORY_button_up"] forState:UIControlStateNormal];
    [categoryButton setImage:[UIImage imageNamed:@"top_menu_CATEGORY_button_down"] forState:UIControlStateHighlighted];
    [categoryButton setImage:[UIImage imageNamed:@"top_menu_CATEGORY_button_down"] forState:UIControlStateSelected];
    [categoryButton addTarget:self action:@selector(showCategoryView:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:categoryButton];

    UIImageView *firstDivider = [[UIImageView alloc] initWithFrame:CGRectMake(106, 0, 1, 36)];
    firstDivider.image = [UIImage imageNamed:@"top_menu_1px_divider"];
    [self.topBar addSubview:firstDivider];

    UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    allButton.frame = CGRectMake(107, 0, 106, 36);
    allButton.tag = fnmAllToggleTag;
    [allButton setImage:[UIImage imageNamed:@"top_menu_ALL_button_up"] forState:UIControlStateNormal];
    [allButton setImage:[UIImage imageNamed:@"top_menu_ALL_button_down"] forState:UIControlStateHighlighted];
    [allButton setImage:[UIImage imageNamed:@"top_menu_ALL_button_down"] forState:UIControlStateSelected];
    [allButton addTarget:self action:@selector(showAllTemplates:) forControlEvents:UIControlEventTouchUpInside];
    allButton.userInteractionEnabled = NO;
    allButton.selected = YES;
    self.currentSelection = allButton;
    [self.topBar addSubview:allButton];

    UIImageView *secondDivider = [[UIImageView alloc] initWithFrame:CGRectMake(213, 0, 1, 36)];
    secondDivider.image = [UIImage imageNamed:@"top_menu_1px_divider"];
    [self.topBar addSubview:secondDivider];

    UIButton *locButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locButton.frame = CGRectMake(214, 0, 106, 36);
    locButton.tag = fnmLocalToggleTag;
    [locButton setImage:[UIImage imageNamed:@"top_menu_LOCATION_button_up"] forState:UIControlStateNormal];
    [locButton setImage:[UIImage imageNamed:@"top_menu_LOCATION_button_down"] forState:UIControlStateHighlighted];
    [locButton setImage:[UIImage imageNamed:@"top_menu_LOCATION_button_down"] forState:UIControlStateSelected];
    [locButton addTarget:self action:@selector(locationTemplatesButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:locButton];
}

- (void)setupPullToRefresh
{
    if (self.refresh == nil) {
        self.refresh = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        self.refresh.tintColor = [UIColor orangeColor];
        self.refresh.activityIndicatorViewColor = [UIColor orangeColor];
        [self.refresh addTarget:self action:@selector(tableShouldRefresh) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)disablePullToRefresh
{
    [self.refresh removeFromSuperview];
    self.refresh = nil;
}

- (void)displayNetworkError
{
    if(self.emptyPlaceholder == nil) {
        NSString *placeholderName = isPhoneFive() ? @"empty_all-templates_instructions_overlay_iPhone5" : @"empty_all-templates_instructions_overlay";
        self.emptyPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:placeholderName]];
        [self.emptyPlaceholder setFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:self.emptyPlaceholder];
        [self.view bringSubviewToFront:self.emptyPlaceholder];
    }

    [[[FNMAlertView alloc] initWithTitle:@"Network Error"
                                 message:@"There was an error attempting to retreive templates, this may be due to low network signal."
                                delegate:nil
                       cancelButtonTitle:@"Okay"
                       otherButtonTitles:nil] show];
}

#pragma mark - Overlay View

- (void)checkForOverlayShown
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownRefreshTutorialOverlay"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasShownRefreshTutorialOverlay"];

        UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlayButton.frame = CGRectMake(0, 0, 320, screenHeight());
        [overlayButton addTarget:self action:@selector(removeOverlay:) forControlEvents:UIControlEventTouchUpInside];
        [overlayButton setImage:[UIImage imageNamed:isPhoneFive()?@"refresh_overlay_five":@"refresh_overlay"] forState:UIControlStateNormal];
        [self.appDelegate.window addSubview:overlayButton];
    }
}

- (void)removeOverlay:(UIButton *)button
{
    [button removeFromSuperview];
}

#pragma mark - Juggle Template Views

- (void)jugglePreviousSelection:(id)sender
{
    if (self.showingLocalTemplates) {
        self.showingLocalTemplates = NO;
    }

    if(self.currentSelection.tag == fnmCategoryToggleTag) {
        [self.currentSelection setImage:[UIImage imageNamed:@"top_menu_CATEGORY_button_up"] forState:UIControlStateNormal];
        [self.currentSelection setImage:[UIImage imageNamed:@"top_menu_CATEGORY_button_down"] forState:UIControlStateHighlighted];
        [self.currentSelection setImage:[UIImage imageNamed:@"top_menu_CATEGORY_button_down"] forState:UIControlStateSelected];
    }

    //self.topBar.userInteractionEnabled = NO;

    [self checkAndCleanCategoryView];
    [self checkAndCleanUserLocalPicker];

    self.currentSelection.selected = NO;
    self.currentSelection.userInteractionEnabled = YES;

    [sender setSelected:YES];
    [sender setUserInteractionEnabled:NO];
    self.currentSelection = sender;

    CATransition *animation = [CATransition animation];
    animation.duration = 0.2;
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionMoveIn;
    [self.currentSelection.layer addAnimation:animation forKey:@"buttonChange"];

    [self.emptyPlaceholder removeFromSuperview];
    self.emptyPlaceholder = nil;
}

- (void)finishBarTransition
{
    self.topBar.userInteractionEnabled = YES;
}

- (void)checkAndCleanCategoryView
{
    if (self.categoryPicker != nil) {
        [self dismissCategoryView];
    }
}

- (void)checkAndCleanUserLocalPicker
{
    if (self.userInputLocationView != nil) {
        [self dismissLocalPicker];
    }
}

- (void)finishTransitionFromLocalToAll
{
    [self displayTemplatesWithoutVenue];
    self.tableView.contentOffset = CGPointZero;
    
    [self.tableView slideInFrom:kFTAnimationBottom
                       duration:.4
                       delegate:self
                  startSelector:Nil
                   stopSelector:@selector(finishBarTransition)];
}

- (void)showAllTemplates:(id)sender
{
    [self jugglePreviousSelection:sender];

    if ((self.showingLocalTemplates || self.categoryPicker == nil) && !self.userInputLocationView) {
        [self.tableView slideOutTo:kFTAnimationBottom
                          duration:.4
                          delegate:self
                     startSelector:Nil
                      stopSelector:@selector(finishTransitionFromLocalToAll)];
    } else {
        [self displayTemplatesWithoutVenue];
        self.tableView.contentOffset = CGPointZero;

        FTAnimationManager *animManager = [FTAnimationManager sharedManager];
        CAAnimation *allTemplates = [animManager slideInAnimationFor:self.tableView
                                                           direction:kFTAnimationBottom
                                                            duration:.4
                                                            delegate:self
                                                       startSelector:Nil
                                                        stopSelector:@selector(finishBarTransition)];
        allTemplates = [animManager delayStartOfAnimation:allTemplates withDelay:(self.categoryPicker ? 1.2 : .4)];

        [CATransaction begin];
        [self.tableView.layer addAnimation:allTemplates forKey:nil];
        [CATransaction commit];
    }
}

- (void)locationTemplatesButtonTouched:(in)sender
{
    self.codeOnly = NO;
    [self showLocalTemplates:sender];
}

- (void)showLocalTemplates:(id)sender
{
    [self jugglePreviousSelection:sender]; //TODO: Causes top bar to stop accepting user input?!
    self.showingLocalTemplates = YES;

    if([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            self.tableView.contentOffset = CGPointZero;
            [self.tableView slideOutTo:kFTAnimationBottom
                              duration:.4
                              delegate:self
                         startSelector:nil
                          stopSelector:@selector(finishShowingLocalTemplates)];
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            // This will trigger the Location Privacy authorization prompt
            [self.locationManager startUpdatingLocation];
        } else { // Denied or restricted
            [self displayLocationServicesErrorAndLocalUserInputView];
        }
    } else {
        [self displayLocationServicesErrorAndLocalUserInputView];
    }
}

- (void)displayLocationServicesErrorAndLocalUserInputView
{
    if (self.displayLocationServicesAccessDeniedWarning) {
        self.displayLocationServicesAccessDeniedWarning = NO;
        [[[FNMAlertView alloc] initWithTitle:@"Location Turned Off"
                                     message:@"You have turned off Fanmento's access to your Location. You can turn it back on in settings, or you can get location specific templates by entering a Venue code."
                                    delegate:nil
                           cancelButtonTitle:@"Okay"
                           otherButtonTitles:nil] show];
    }

    if (self.categoryPicker) {
        [self performSelector:@selector(buildAndShowLocalUserInputView)
                   withObject:nil
                   afterDelay:1.2];
    } else {
        [self.tableView slideOutTo:kFTAnimationBottom
                          duration:.4
                          delegate:self
                     startSelector:Nil
                      stopSelector:@selector(buildAndShowLocalUserInputView)];
    }
}

- (void)finishShowingLocalTemplates
{
    if (! self.codeOnly) {
        [self.hud show:YES];

        // Start getting the users location
        [self.locationManager startUpdatingLocation];
    } else {
        [self buildAndShowLocalUserInputView];
    }
}

- (void)showCategoryView:(id)sender
{
    [self jugglePreviousSelection:sender];

    if (self.userInputLocationView != nil) {
        [self performSelector:@selector(buildAndShowCategoryView) withObject:nil afterDelay:.4];
    } else {
        [self.tableView slideOutTo:kFTAnimationBottom
                          duration:.4
                          delegate:self
                     startSelector:Nil
                      stopSelector:@selector(buildAndShowCategoryView)];
    }
}

- (void)updateTemplatesToDisplayWithArray:(NSArray *)newTemplates
{
    [self.templatesToDisplay removeAllObjects];

    for(FNMTemplate *template in newTemplates) {
        if(template.cRemoteURL && ! [self.templatesToDisplay containsObject:template.cRemoteURL]) {
            [self.templatesToDisplay addObject:template.cRemoteURL];
        }
    }

    DLog(@"Number of templates to display: %lu", (unsigned long)[self.templatesToDisplay count]);
}

# pragma mark - All View

- (void)setupTable
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 36.0, 320.0, screenHeight()-tabBarHeight()-36) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"FNMCustomGalleryCell" bundle:nil] forCellReuseIdentifier:@"FNMCustomGalleryCell"];
    [self.view addSubview:self.tableView];

    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 34, 320, 20)];
    shadow.image = [UIImage imageNamed:@"shadow_top"];
    [self.view addSubview:shadow];
}

- (void)displayTemplatesWithoutVenue
{
    self.topBar.userInteractionEnabled = NO;
    [self.hud show:YES];

    if([self shouldRetrieveTemplatesWithoutVenueFromCache]) {
        [self updateTemplatesToDisplayWithArray:[FNMTemplate getAllTemplatesWithoutVenue]];
    }

    // If we were able to find cached templates
    if(self.templatesToDisplay.count > 0) {
        [self endRefreshAndUpdateTable];
    } else {
        self.currentTemplatesWithoutVenuePage = 0;
        [self getNextPageOfTemplatesWithoutVenue];
    }
}

- (BOOL)shouldRetrieveTemplatesWithoutVenueFromCache
{
    NSDate *lastRefreshedDate = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_TEMPLATES_WITHOUT_VENUE_REFRESH_KEY];
    NSDate *shouldRefreshDate = [lastRefreshedDate dateByAddingTimeInterval:TEMPLATES_WITHOUT_VENUE_REFRESH_DELAY];

    if([shouldRefreshDate compare:[NSDate date]] == NSOrderedAscending || lastRefreshedDate == nil) {
        return NO;
    } else {
        return YES;
    }
}

- (void)getNextPageOfTemplatesWithoutVenue
{
    self.currentTemplatesWithoutVenuePage++;
    self.loadingMorePages = YES;
    [self disablePullToRefresh];

    [FNMAPI_Templates syncTemplatesWithoutVenuePage:self.currentTemplatesWithoutVenuePage withCompletion:^(BOOL success, BOOL morePages) {
        self.loadingMorePages = morePages;
        if(success) {
            [self updateTemplatesToDisplayWithArray:[FNMTemplate getAllTemplatesWithoutVenue]];

            // Remove the HUD so the user can interact with the app
            [self endRefreshAndUpdateTable];

            // If there are more templates available, continue retrieving them in the background
            if(morePages)  {
                [self getNextPageOfTemplatesWithoutVenue];
            } else { // Once we've retrieved all of the templates, update the refresh date
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULTS_TEMPLATES_WITHOUT_VENUE_REFRESH_KEY];
                [self setupPullToRefresh];
            }
        } else {
            [self displayNetworkError];
            [self endRefreshAndUpdateTable];
            [self setupPullToRefresh];
        }
    }];
}

#pragma mark - Local View

- (void)buildAndShowLocalUserInputView
{
    if (self.userInputLocationView == nil) {
        self.userInputLocationView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height, 320, self.tableView.frame.size.height)];
        self.userInputLocationView.backgroundColor = [UIColor clearColor];

        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 298)];
        bg.contentMode = UIViewContentModeCenter;
        bg.image = [UIImage imageNamed:(self.codeOnly) ? @"code-only" : @"no-connection_text"];
        [self.userInputLocationView addSubview:bg];

        UIImageView *textBg = [[UIImageView alloc] initWithFrame:CGRectMake(56, 160, 208, 50)];
        textBg.image = [UIImage imageNamed:@"digit_code_input"];
        [self.userInputLocationView addSubview:textBg];

        self.codeEntry = [[UITextField alloc] initWithFrame:CGRectInset(textBg.frame, 20, 15)];
        self.codeEntry.delegate = self;
        self.codeEntry.textAlignment = NSTextAlignmentCenter;
        self.codeEntry.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.codeEntry.autocorrectionType = UITextAutocorrectionTypeNo;
        self.codeEntry.returnKeyType = UIReturnKeyDone;
        self.codeEntry.borderStyle = UITextBorderStyleNone;
        [self.userInputLocationView addSubview:self.codeEntry];

        self.tryCode = [UIButton buttonWithType:UIButtonTypeCustom];
        self.tryCode.frame = CGRectMake(50, 220, 106, 39);
        [self.tryCode setImage:[UIImage imageNamed:@"enter_code_button"] forState:UIControlStateNormal];
        [self.tryCode addTarget:self action:@selector(loadTemplatesForCode) forControlEvents:UIControlEventTouchUpInside];
        self.tryCode.enabled = NO;
        [self.userInputLocationView addSubview:self.tryCode];

        UIButton *cancelCode = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelCode.frame = CGRectMake(165, 220, 106, 39);
        [cancelCode setImage:[UIImage imageNamed:@"cancel_code_button"] forState:UIControlStateNormal];
        SEL action = (self.codeOnly) ? @selector(returnToSettings) : @selector(clearCodeField);
        [cancelCode addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self.userInputLocationView addSubview:cancelCode];

        if (! self.codeOnly) {
            UIButton *selectLocation = [UIButton buttonWithType:UIButtonTypeCustom];
            selectLocation.frame = CGRectMake(21, 320, 283, 43);
            [selectLocation setImage:[UIImage imageNamed:@"select_location_button"] forState:UIControlStateNormal];
            [selectLocation addTarget:self action:@selector(presentLocationPicker) forControlEvents:UIControlEventTouchUpInside];
            [self.userInputLocationView addSubview:selectLocation];
        }

        [self.view addSubview:self.userInputLocationView];
    }

    [self.userInputLocationView slideInFrom:kFTAnimationBottom
                                   duration:.4
                                   delegate:self
                              startSelector:Nil
                               stopSelector:@selector(finishBarTransition)];

    if (! self.codeOnly) {
        [self setupPicker];
    }
}

- (void)captureLocationCode
{
    self.codeOnly = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.userInputLocationView removeFromSuperview];
        self.userInputLocationView = nil;

        [self showLocalTemplates:[self.view viewWithTag:fnmLocalToggleTag]];

        int64_t delayInSeconds = 1.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tableShouldRefresh];
        });
    });
}

- (void)updateVenueNames
{
    if([self shouldUpdateVenueList]) {
        [FNMAPI_Venue syncAllLocationsCompletion:^(BOOL success, id object) {
            if(success) {
                [self handleVenueListUpdate];
            }
        }];
    }
}

- (BOOL)shouldUpdateVenueList
{
    NSDate *lastRefreshedDate = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_LAST_VENUE_LIST_REFRESH_KEY];
    NSDate *shouldRefreshDate = [lastRefreshedDate dateByAddingTimeInterval:VENUE_LIST_REFRESH_DELAY];

    if([shouldRefreshDate compare:[NSDate date]] == NSOrderedAscending || lastRefreshedDate == nil) {
        return YES;
    } else {
        return NO;
    }
}

- (void)handleVenueListUpdate
{
    self.possibleVenues = [FNMVenue getCurrentVenues];

    if (self.picker != nil) {
        [self.picker reloadAllComponents];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULTS_LAST_VENUE_LIST_REFRESH_KEY];
}

- (void)returnToSettings
{
    self.appDelegate.tabBarController.selectedIndex = 3;
}

- (void)clearCodeField
{
    [self.codeEntry setText:@""];
    [self.tryCode setEnabled:NO];
}

- (void)loadTemplatesForCode
{
    [self.view bringSubviewToFront:self.hud];
    [self.hud show:YES];
    self.currentLocationSource = fnmCode;
    // Pull to refresh won't have a text field, check before overwriting
    if(self.codeEntry.text) {
        self.currentCode = self.codeEntry.text;
    }

    [FNMAPI_Templates syncTemplatesForCode:self.currentCode withCompletion:^(BOOL success) {
        [self.refresh endRefreshing];
        [self.hud hide:YES];
        [self.appDelegate trackPageViewWithName:@"Templates requested via Code"];

        if (success) {
            [self updateTemplatesToDisplayWithArray:[FNMTemplate getTemplatesForCode:self.currentCode]];

            if (self.templatesToDisplay.count == 0) {
                [[[FNMAlertView alloc] initWithTitle:@"Invalid Code"
                                             message:@"We were unable to find any templates that match this code."
                                            delegate:nil
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil] show];
            } else {
                if (self.pickerView) {
                    [self hideVenuePicker];
                }
                [self dismissLocalPicker];
                [self.tableView slideInFrom:kFTAnimationBottom
                                   duration:.4
                                   delegate:self
                              startSelector:Nil
                               stopSelector:@selector(finishBarTransition)];
                [self endRefreshAndUpdateTable];
            }
        } else {
            [[[FNMAlertView alloc] initWithTitle:@"Connection Error"
                                         message:@"There was a connection error, posibly due to low signal. Please try again later."
                                        delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];
        }
    }];
}

- (void)dismissLocalPicker
{
    [self.userInputLocationView slideOutTo:kFTAnimationBottom
                                  duration:.4
                                  delegate:self
                             startSelector:Nil
                              stopSelector:@selector(cleanupLocalPicker)];
}

- (void)cleanupLocalPicker
{
    [self.codeEntry removeFromSuperview];
    self.codeEntry = nil;

    if (self.pickerView) {
        [self.picker removeFromSuperview];
        [self.doneBar removeFromSuperview];
        [self.pickerView removeFromSuperview];

        self.picker = nil;
        self.doneBar = nil;
        self.pickerView = nil;
    }

    [self.userInputLocationView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.userInputLocationView removeFromSuperview];
    self.userInputLocationView = nil;
}

- (void)presentLocationPicker
{
    self.possibleVenues = [FNMVenue getCurrentVenues];
    if(self.possibleVenues.count != 0) {
        [self.picker reloadAllComponents];
        [self.pickerView slideInFrom:kFTAnimationBottom
                            duration:.4
                            delegate:nil];
    } else {
        [FNMAPI_Venue syncAllLocationsCompletion:^(BOOL success, id object) {
            if(success) {
                [self handleVenueListUpdate];
            } else {
                [[[FNMAlertView alloc] initWithTitle:@"Unable To Find Venues"
                                             message:@"No Venues Found"
                                            delegate:nil
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil] show];
            }
        }];
    }
}

- (void)setupPicker
{
    self.possibleVenues = @[];

    if (self.picker == nil) {
        self.pickerView = [[UIView alloc] initWithFrame:self.view.frame];
        self.pickerView.backgroundColor = [UIColor clearColor];
        self.pickerView.hidden = YES;

        self.picker = [[UIPickerView alloc] init];
        self.picker.showsSelectionIndicator = YES;
        self.picker.delegate = self;
        self.picker.dataSource = self;
        self.picker.frame = CGRectMake(0, self.pickerView.frame.size.height-self.topBar.frame.size.height-216, 320, 216);
        self.picker.backgroundColor = [UIColor whiteColor];
        [self.pickerView addSubview:self.picker];

        self.doneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.picker.frame.origin.y-36, 320, 36)];
        self.doneBar.barStyle = UIBarStyleBlack;
        self.doneBar.translucent = YES;

        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(pickerDoneClicked:)];
        doneButton.tintColor = [UIColor whiteColor];

        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];

        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(hideVenuePicker)];
        cancelButton.tintColor = [UIColor whiteColor];

        [self.doneBar setItems:@[cancelButton, spacer, doneButton]];

        [self.pickerView addSubview:self.doneBar];
        [self.userInputLocationView addSubview:self.pickerView];
    } else {
        [self.view bringSubviewToFront:self.pickerView];
    }
}

- (void)hideVenuePicker
{
    [self.pickerView slideOutTo:kFTAnimationBottom
                       duration:.4
                       delegate:nil];
}

- (void)pickerDoneClicked:(id)sender
{
    [self hideVenuePicker];
    [self dismissLocalPicker];

    // Get the venue lat/long and make an API request
    self.currentVenue = self.possibleVenues[[self.picker selectedRowInComponent:0]];
    [self getTemplatesForSelectedVenue];
}

- (void)getTemplatesForSelectedVenue
{
    CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:self.currentVenue.cLatitude.floatValue
                                                           longitude:self.currentVenue.cLongitude.floatValue];

    // Start retrieveing templates
    self.currentLocationPage = 0;
    self.currentLocationSource = fnmVenueLocation;
    [self.hud show:YES];
    [self getNextPageOfTemplatesForLocation:venueLocation];
}

- (void)getNextPageOfTemplatesForLocation:(CLLocation *)location
{
    self.currentLocationPage++;
    self.loadingMorePages = YES;
    [self disablePullToRefresh];

    [FNMAPI_Templates syncTemplatesForLocation:location page:self.currentLocationPage withCompletion:^(BOOL success, BOOL morePages) {
        [self.hud hide:YES];
        self.loadingMorePages = morePages;
        self.loadingFirstPageOfLocationTemplates = NO;
        if(success) {
            [self updateTemplatesToDisplayWithArray:[FNMTemplate getTemplatesForLocation:location]];

            // Slide the table into view
            [self.tableView slideInFrom:kFTAnimationBottom
                               duration:.4
                               delegate:self
                          startSelector:Nil
                           stopSelector:@selector(finishBarTransition)];


            // Remove the HUD so the user can interact with the app
            [self endRefreshAndUpdateTable];

            if(! morePages) {
                [self setupPullToRefresh];
            }
        } else {
            [[[FNMAlertView alloc] initWithTitle:@"No Templates"
                                         message:@"There are currently no active Templates associated with this venue"
                                        delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];

            [self buildAndShowLocalUserInputView];
            [self setupPullToRefresh];
        }
    }];
}

#pragma mark - Category View

- (void)buildAndShowCategoryView
{
    self.categoryPicker = [[UIView alloc]initWithFrame:CGRectMake(0, self.topBar.frame.size.height, 320, self.tableView.frame.size.height)];
    self.categoryPicker.backgroundColor = [UIColor clearColor];

    UIButton *sportsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sportsButton setFrame:CGRectMake(0, 32, 320, 58)];
    [sportsButton setImage:[UIImage imageNamed:@"category_SPORTS_button_up"] forState:UIControlStateNormal];
    [sportsButton setImage:[UIImage imageNamed:@"category_SPORTS_button_down"] forState:UIControlStateHighlighted];
    [sportsButton setTag:fnmSportsTemplates];
    [sportsButton addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
    [sportsButton setHidden:YES];
    [self.categoryPicker addSubview:sportsButton];

    UIButton *entertainmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [entertainmentButton setFrame:CGRectMake(0, 96, 320, 58)];
    [entertainmentButton setImage:[UIImage imageNamed:@"category_ENTERTAINMENT_button_up"] forState:UIControlStateNormal];
    [entertainmentButton setImage:[UIImage imageNamed:@"category_ENTERTAINMENT_button_down"] forState:UIControlStateHighlighted];
    [entertainmentButton setTag:fnmEntertainmentTemplates];
    [entertainmentButton setHidden:YES];
    [entertainmentButton addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.categoryPicker addSubview:entertainmentButton];

    UIButton *musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [musicButton setFrame:CGRectMake(0, 160, 320, 58)];
    [musicButton setImage:[UIImage imageNamed:@"category_MUSIC_button_up"] forState:UIControlStateNormal];
    [musicButton setImage:[UIImage imageNamed:@"category_MUSIC_button_down"] forState:UIControlStateHighlighted];
    [musicButton setTag:fnmMusicTemplates];
    [musicButton setHidden:YES];
    [musicButton addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.categoryPicker addSubview:musicButton];

    UIButton *lifestyleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lifestyleButton setFrame:CGRectMake(0, 224, 320, 58)];
    [lifestyleButton setImage:[UIImage imageNamed:@"category_LIFESTYLE_button_up"] forState:UIControlStateNormal];
    [lifestyleButton setImage:[UIImage imageNamed:@"category_LIFESTYLE_button_down"] forState:UIControlStateHighlighted];
    [lifestyleButton setTag:fnmLifestyleTemplates];
    [lifestyleButton setHidden:YES];
    [lifestyleButton addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.categoryPicker addSubview:lifestyleButton];

    UIButton *miscButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [miscButton setFrame:CGRectMake(0, 288, 320, 58)];
    [miscButton setImage:[UIImage imageNamed:@"category_MISCELLANEOUS_button_up"] forState:UIControlStateNormal];
    [miscButton setImage:[UIImage imageNamed:@"category_MISCELLANEOUS_button_down"] forState:UIControlStateHighlighted];
    [miscButton setTag:fnmMiscellaneousTemplates];
    [miscButton setHidden:YES];
    [miscButton addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.categoryPicker addSubview:miscButton];

    [self.view addSubview:self.categoryPicker];

    FTAnimationManager *animManager = [FTAnimationManager sharedManager];

    CAAnimation *sports = [animManager backInAnimationFor:[self.categoryPicker viewWithTag:fnmSportsTemplates]
                                                 withFade:NO
                                                direction:kFTAnimationBottom
                                                 duration:.6f
                                                 delegate:nil
                                            startSelector:nil
                                             stopSelector:nil];

    CAAnimation *entertain = [animManager backInAnimationFor:[self.categoryPicker viewWithTag:fnmEntertainmentTemplates]
                                                    withFade:NO
                                                   direction:kFTAnimationBottom
                                                    duration:.6f
                                                    delegate:nil
                                               startSelector:nil
                                                stopSelector:nil];
    entertain = [animManager delayStartOfAnimation:entertain withDelay:.15];

    CAAnimation *music = [animManager backInAnimationFor:[self.categoryPicker viewWithTag:fnmMusicTemplates]
                                                withFade:NO
                                               direction:kFTAnimationBottom
                                                duration:.6f
                                                delegate:nil
                                           startSelector:nil
                                            stopSelector:nil];
    music = [animManager delayStartOfAnimation:music withDelay:.3];

    CAAnimation *lifestyle = [animManager backInAnimationFor:[self.categoryPicker viewWithTag:fnmLifestyleTemplates]
                                                    withFade:NO
                                                   direction:kFTAnimationBottom
                                                    duration:.6f
                                                    delegate:nil
                                               startSelector:nil
                                                stopSelector:nil];
    lifestyle = [animManager delayStartOfAnimation:lifestyle withDelay:.45];

    CAAnimation *misc = [animManager backInAnimationFor:[self.categoryPicker viewWithTag:fnmMiscellaneousTemplates]
                                               withFade:NO
                                              direction:kFTAnimationBottom
                                               duration:.6f
                                               delegate:nil
                                          startSelector:nil
                                           stopSelector:nil];
    misc = [animManager delayStartOfAnimation:misc withDelay:.6];
    [misc setStopSelector:@selector(finishBarTransition) withTarget:self];

    [CATransaction begin];
    [[self.categoryPicker viewWithTag:fnmSportsTemplates].layer addAnimation:sports forKey:nil];
    [[self.categoryPicker viewWithTag:fnmEntertainmentTemplates].layer addAnimation:entertain forKey:nil];
    [[self.categoryPicker viewWithTag:fnmMusicTemplates].layer addAnimation:music forKey:nil];
    [[self.categoryPicker viewWithTag:fnmLifestyleTemplates].layer addAnimation:lifestyle forKey:nil];
    [[self.categoryPicker viewWithTag:fnmMiscellaneousTemplates].layer addAnimation:misc forKey:nil];
    [CATransaction commit];
}

- (void)categorySelected:(UIButton*)sender
{
    [self updateTemplatesToDisplayWithArray:[FNMTemplate getTemplatesForCategory:categoryNames[sender.tag]]];

    if (self.templatesToDisplay.count) {
        self.currentCategory = sender.tag;

        [self dismissCategoryView];
        [self.tableView reloadData];

        int64_t delayInSeconds = 1.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.currentSelection setImage:[UIImage imageNamed:@"category_back_button"] forState:UIControlStateNormal];
            [self.currentSelection setImage:[UIImage imageNamed:@"category_back_button"] forState:UIControlStateHighlighted];

            self.currentSelection.selected = NO;
            self.currentSelection.userInteractionEnabled = YES;

            CATransition *animation = [CATransition animation];
            animation.duration = 0.2;
            animation.type = kCATransitionFade;
            animation.subtype = kCATransitionMoveIn;

            [self.currentSelection.layer addAnimation:animation forKey:@"fadebutton"];

            self.tableView.contentOffset = CGPointZero;
            [self.tableView slideInFrom:kFTAnimationBottom
                               duration:.4
                               delegate:self
                          startSelector:Nil
                           stopSelector:@selector(finishBarTransition)];
        });
    } else {
        [[[FNMAlertView alloc] initWithTitle:@"No Templates"
                                     message:@"There are currently no templates for this category"
                                    delegate:nil
                           cancelButtonTitle:@"Okay"
                           otherButtonTitles:nil] show];
    }
}

- (void)dismissCategoryView
{
    FTAnimationManager *animManager = [FTAnimationManager sharedManager];

    CAAnimation *sports = [animManager backOutAnimationFor:[self.categoryPicker viewWithTag:fnmSportsTemplates]
                                                  withFade:NO
                                                 direction:kFTAnimationBottom
                                                  duration:.6f
                                                  delegate:nil
                                             startSelector:nil
                                              stopSelector:nil];

    CAAnimation *entertain = [animManager backOutAnimationFor:[self.categoryPicker viewWithTag:fnmEntertainmentTemplates]
                                                     withFade:NO
                                                    direction:kFTAnimationBottom
                                                     duration:.6f
                                                     delegate:nil
                                                startSelector:nil
                                                 stopSelector:nil];
    entertain = [animManager delayStartOfAnimation:entertain withDelay:.15];

    CAAnimation *music = [animManager backOutAnimationFor:[self.categoryPicker viewWithTag:fnmMusicTemplates]
                                                 withFade:NO
                                                direction:kFTAnimationBottom
                                                 duration:.6f
                                                 delegate:nil
                                            startSelector:nil
                                             stopSelector:nil];
    music = [animManager delayStartOfAnimation:music withDelay:.3];

    CAAnimation *lifestyle = [animManager backOutAnimationFor:[self.categoryPicker viewWithTag:fnmLifestyleTemplates]
                                                     withFade:NO
                                                    direction:kFTAnimationBottom
                                                     duration:.6f
                                                     delegate:nil
                                                startSelector:nil
                                                 stopSelector:nil];
    lifestyle = [animManager delayStartOfAnimation:lifestyle withDelay:.45];

    CAAnimation *misc = [animManager backOutAnimationFor:[self.categoryPicker viewWithTag:fnmMiscellaneousTemplates]
                                                withFade:NO
                                               direction:kFTAnimationBottom
                                                duration:.6f
                                                delegate:nil
                                           startSelector:nil
                                            stopSelector:nil];
    misc = [animManager delayStartOfAnimation:misc withDelay:.6];

    [music setStopSelector:@selector(cleanupCategoryPicker) withTarget:self];

    [CATransaction begin];
    [[self.categoryPicker viewWithTag:fnmSportsTemplates].layer addAnimation:sports forKey:nil];
    [[self.categoryPicker viewWithTag:fnmEntertainmentTemplates].layer addAnimation:entertain forKey:nil];
    [[self.categoryPicker viewWithTag:fnmMusicTemplates].layer addAnimation:music forKey:nil];
    [[self.categoryPicker viewWithTag:fnmLifestyleTemplates].layer addAnimation:lifestyle forKey:nil];
    [[self.categoryPicker viewWithTag:fnmMiscellaneousTemplates].layer addAnimation:misc forKey:nil];
    [CATransaction commit];
}

- (void)cleanupCategoryPicker
{
    [self.categoryPicker.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.categoryPicker removeFromSuperview];
    self.categoryPicker = nil;
}

#pragma mark - Pull To Refresh Handler

- (void)tableShouldRefresh
{
    [self.topBar setUserInteractionEnabled:NO];
    [self.hud show:YES];

    switch (self.currentSelection.tag) {
        case fnmAllToggleTag:
        {
            // Remove templates from view
            [self updateTemplatesToDisplayWithArray:nil];
            [self.tableView reloadData];

            [self.emptyPlaceholder removeFromSuperview];
            self.emptyPlaceholder = nil;
            self.currentTemplatesWithoutVenuePage = 0;
            [self getNextPageOfTemplatesWithoutVenue];

            break;
        }

        case fnmCategoryToggleTag:
        {
            [self endRefreshAndUpdateTable];

            break;
        }

        case fnmLocalToggleTag:
        {
            // Could be displaying based on current location, venue, or code
            if (! self.codeOnly) {
                [self updateTemplatesToDisplayWithArray:nil];
                [self.tableView reloadData];
                if(self.currentLocationSource == fnmVenueLocation && self.currentVenue != nil) {
                    [self getTemplatesForSelectedVenue];
                } else if(self.currentLocationSource == fnmCode && self.currentCode) {
                    [self loadTemplatesForCode];
                } else { // Get the users current location and retrive templates
                    [self.locationManager startUpdatingLocation];
                }
            } else {
                [self endRefreshAndUpdateTable];
            }

            break;
        }

        default:
            break;
    }
}

- (void)endRefreshAndUpdateTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.topBar setUserInteractionEnabled:YES];
        [self.hud hide:YES];
        [self.tableView reloadData];
        [self.refresh endRefreshing];
    });
}

#pragma mark - FNMCustomGalleryCellDelegate

- (void)imageSelected:(UITapGestureRecognizer *)theTap
{
    FNMGalleryDetailViewController *vc = [[FNMGalleryDetailViewController alloc] initWithImage:nil];
    NSString *url = objc_getAssociatedObject(theTap.view, (const void*)0x314);
    if (url) {
        FNMTemplate *template = [FNMTemplate getTemplateForImageURL:url];

        if (template != nil) {
            if ([template.cIsPremium boolValue] && ![template.cIsPurchased boolValue]) {
                [self beginPurchaseFlow:template];
                return;
            } else {
                DLog(@"Template %@", template.cEffect);
                [vc setSelectedTemplate:template];
            }
        }
    } else {
        [vc setTemplateImage:[(UIImageView *)theTap.view image]];
    }

    
#if TARGET_IPHONE_SIMULATOR
    
    //Simulator
    [self dismissViewControllerAnimated:NO completion:^{
        [FNMAppDelegate appDelegate].myCollectionViewController.selectedPicture = [(UIImageView *)theTap.view image];
        [FNMAppDelegate appDelegate].myCollectionViewController.shareScreenMode = YES;
        
        NSDictionary *test = objc_getAssociatedObject([(UIImageView *)theTap.view image], (const void*)0x314);
        
        if ([FNMAppDelegate appDelegate].myCollectionViewController.detailViewBackground) {
            [[FNMAppDelegate appDelegate].myCollectionViewController.detailViewBackground removeFromSuperview];
            [FNMAppDelegate appDelegate].myCollectionViewController.detailViewBackground = nil;
        }
        
        id backgroundURL = [test objectForKey:@"background"];
        if (![[NSNull null] isEqual:backgroundURL] && backgroundURL != nil) {
            [FNMAppDelegate appDelegate].myCollectionViewController.detailViewBackground = [[VILoaderImageView alloc]initWithFrame:CGRectMake(0, 0, 320, screenHeight())
                                                                                                                          imageUrl:backgroundURL
                                                                                                                          animated:YES];
        }
        
        [[[FNMAppDelegate appDelegate] tabBarController] setSelectedViewController:[FNMAppDelegate appDelegate].myCollectionViewController];
    }];
    
#else
    
    // Device
    [self presentViewController:vc animated:NO completion:nil];
    
#endif
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isLoadingCellRow:indexPath]) {
        return 88.0f;
    } else if (indexPath.row == (self.rowCount-1)) {
        return 220.0f;
    } else {
        return 206.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retVal = 0;
    if (self.appDelegate.tabBarController.selectedIndex == 1) {
        retVal = ceil(self.templatesToDisplay.count / 2.0);
        // Add a row for loading indicator if still retrieving pages
        if(self.loadingMorePages) {
            retVal++;
        }
    }

    self.rowCount = retVal;
    return retVal;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isLoadingCellRow:indexPath]) {
        return [self createLoadingCellForTableView:tableView];
    }

    static NSString *ident = @"FNMCustomGalleryCell";
    FNMCustomGalleryCell *cell = (FNMCustomGalleryCell *)[self.tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = (FNMCustomGalleryCell *)[[FNMCustomGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(cellImageSelected:)];

    [self cancelCell:cell];
    cell.delegate = self;

    UIImageView*leftCorner = (UIImageView*)[cell viewWithTag:fnmLeftPremiumCorner];
    [leftCorner setHidden:YES];

    UIImageView*rightCorner = (UIImageView*)[cell viewWithTag:fnmRightPremiumCorner];
    [rightCorner setHidden:YES];

    UIImageView* btnLeft = (UIImageView *)[cell viewWithTag:1];
    [btnLeft setImage:nil];

    objc_removeAssociatedObjects(btnLeft);

    id imageObject = nil;

    if (indexPath.row*2 < self.templatesToDisplay.count) {
        imageObject = [self.templatesToDisplay objectAtIndex:(indexPath.row*2)];
    }
    if ([imageObject isKindOfClass:[NSString class]]) {
        FNMTemplate *template = [FNMTemplate getTemplateForImageURL:imageObject];
        if ([template.cIsPremium boolValue]) {
            [leftCorner setHidden:NO];
        }

        __block UIImageView *imageViewBlock = btnLeft;
        [(VILoaderImageView*)btnLeft setImageWithURL:[NSString stringWithFormat:@"%@=s392",(NSString*)imageObject]
                                    placeholderImage:[UIImage imageNamed:@"bg_blank_for_pics"]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.3 animations:^{
                    [imageViewBlock setAlpha:1];
                }];
            });
        }];
        objc_setAssociatedObject(btnLeft, (const void*)0x314,
                                 [NSString stringWithFormat:@"%@",(NSString*)imageObject],
                                 OBJC_ASSOCIATION_RETAIN);
    } else if([imageObject isKindOfClass:[UIImage class]]){
        [btnLeft setImage:(UIImage*)imageObject];
    }

    [btnLeft addGestureRecognizer:tap];

    UIImageView* btnRight = (UIImageView *)[cell viewWithTag:2];
    [btnRight setImage:nil];

    tap = [[UITapGestureRecognizer alloc]initWithTarget:cell action:@selector(cellImageSelected:)];
    [btnRight addGestureRecognizer:tap];
    [btnRight setHidden:NO];
    objc_removeAssociatedObjects(btnRight);

    [[cell viewWithTag:-2] setHidden:NO];

    if ([self.templatesToDisplay count] % 2 == 0 || (indexPath.row + 1) != [self tableView:self.tableView numberOfRowsInSection:0]) {
        imageObject = nil;
        if (indexPath.row*2+1 < self.templatesToDisplay.count) {
            imageObject = [self.templatesToDisplay objectAtIndex:(indexPath.row*2+1)];
        }

        if ([imageObject isKindOfClass:[NSString class]]) {
            FNMTemplate *template = [FNMTemplate getTemplateForImageURL:imageObject];
            if ([template.cIsPremium boolValue]) {
                [rightCorner setHidden:NO];
            }
            __block UIImageView*imageViewBlock = btnRight;

            [(VILoaderImageView*)btnRight setImageWithURL:[NSString stringWithFormat:@"%@=s392",(NSString*)imageObject]
                                         placeholderImage:[UIImage imageNamed:@"bg_blank_for_pics"]
                                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:.3 animations:^{
                        [imageViewBlock setAlpha:1];
                    }];
                });
            }];
            objc_setAssociatedObject(btnRight, (const void*)0x314, [NSString stringWithFormat:@"%@",(NSString*)imageObject], OBJC_ASSOCIATION_RETAIN);
        } else if ([imageObject isKindOfClass:[UIImage class]]){
            [btnRight setImage:(UIImage*)imageObject];
        }
    } else {
        [[cell viewWithTag:-2] setHidden:YES];
        [btnRight setHidden:TRUE];
    }

    return cell;
}

- (void)cancelCell:(UITableViewCell*)cell
{
    [(VILoaderImageView *)[cell viewWithTag:2] sd_cancelCurrentImageLoad];
    [(VILoaderImageView *)[cell viewWithTag:1] sd_cancelCurrentImageLoad];
}

- (UITableViewCell *)createLoadingCellForTableView:(UITableView *)tableView
{
    static NSString *loadingCellIdentifier = @"LoadingCell";
    UITableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier];
    if(loadingCell == nil) {
        loadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellIdentifier];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Fanmento_Grey_Background"]];
        [loadingCell.contentView addSubview:backgroundImageView];
        //[self.view addSubview:backgroundImageView];
        //backgroundImageView.frame = CGRectMake(0,0,320,screenHeight()-30);
        loadingCell.contentView.backgroundColor = [UIColor clearColor];

        UIActivityIndicatorView *loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadingActivityIndicator.color = [UIColor orangeColor];
        loadingActivityIndicator.frame = CGRectMake(loadingCell.contentView.center.x - 10.0f, 10.0f, 20.0f, 20.0f);
        [loadingCell.contentView addSubview:loadingActivityIndicator];
        [loadingActivityIndicator startAnimating];
    }

    // The activity indicator will stop animating when the cell is dequeued and may need to be restarted
    [[loadingCell.contentView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)obj startAnimating];
        }
    }];
    
    return loadingCell;
}

- (BOOL)isLoadingCellRow:(NSIndexPath *)indexPath
{
    return self.loadingMorePages && (indexPath.row == ceil(self.templatesToDisplay.count / 2.0));
}

#pragma mark - Picker Delegate/Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.possibleVenues.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return ((FNMVenue*)[self.possibleVenues objectAtIndex:row]).cName;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 36;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowWidthForComponent:(NSInteger)component
{
    return 320;
}

#pragma mark - In App Purchase Flow

- (void)beginPurchaseFlow:(FNMTemplate*)template
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud setLabelText:@"Loading..."];
        [self.hud show:YES];
    });

    static NSString *errorMessage = @"We are unable to complete this request, you may not have internet service, or Apple's servers may be down.";
    [[DEStoreKitManager sharedManager]
     fetchProductsWithIdentifiers:[NSSet setWithObject:template.cProductIdentifier]
                        onSuccess: ^(NSArray *products, NSArray *invalidIdentifiers) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.hud hide:YES];
                            });
                            DLog(@"Products %@, Invalid Identifiers %@", [products description], [invalidIdentifiers description]);

                            if (products.count>0) {
                                [[DEStoreKitManager sharedManager] purchaseProduct:(SKProduct*)[products lastObject]
                                                                         onSuccess:^(SKPaymentTransaction *transaction) {
                                                                             [FNMTemplate setTemplateBought:template];
                                                                             FNMGalleryDetailViewController* vc =
                                                                             [[FNMGalleryDetailViewController alloc] initWithImage:nil];
                                                                             [vc setSelectedTemplate:template];

                                                                             [self presentViewController:vc animated:YES completion:nil];
                                                                         } onRestore:nil onFailure:^(SKPaymentTransaction *transaction) {
                                                                             [[[FNMAlertView alloc]initWithTitle:@"Unable To Connect"
                                                                                                         message:errorMessage
                                                                                                        delegate:nil
                                                                                               cancelButtonTitle:@"Okay"
                                                                                               otherButtonTitles:nil] show];
                                                                         } onCancel:^(SKPaymentTransaction *transaction) {
                                                                             // Do nothing
                                                                         } onVerify:nil
                                 ];
                            } else {
                                [[[FNMAlertView alloc] initWithTitle:@"Unable To Find"
                                                             message:errorMessage
                                                            delegate:nil
                                                   cancelButtonTitle:@"Okay"
                                                   otherButtonTitles:nil] show];
                            }
                        } onFailure: ^(NSError *error) {
                            DLog(@"error %@", [error description]);
                            [[[FNMAlertView alloc] initWithTitle:@"Unable To Connect"
                                                         message:errorMessage
                                                        delegate:nil
                                               cancelButtonTitle:@"Okay"
                                               otherButtonTitles:nil] show];
                        }
     ];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    self.tryCode.enabled = newLength >= 1;
    return (newLength > 5) ? NO : YES;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations[0];
    // The first location sent may be an old, cached location
    if(abs(newLocation.timestamp.timeIntervalSinceNow) < 5) {
        [self.locationManager stopUpdatingLocation];
        // This method may be called multiple times before we can stop updating the location
        // Only continue if we are not already in the process of loading the first page of location based templates
        if(! self.loadingFirstPageOfLocationTemplates) {
            self.loadingFirstPageOfLocationTemplates = YES;
            self.currentLocationPage = 0;
            self.currentLocationSource = fnmUserLocation;
            [self getNextPageOfTemplatesForLocation:newLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self showLocalTemplates:[self.view viewWithTag:fnmLocalToggleTag]];
}

@end
