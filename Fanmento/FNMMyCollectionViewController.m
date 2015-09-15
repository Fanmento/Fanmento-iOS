//
//  FNMMyCollectionViewController.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryViewController.h"
#import "FNMMyCollectionViewController.h"
#import "FNMOrderPrintsViewController.h"
#import "FNMSettingsViewController.h"
#import "FNMAppDelegate.h"
#import "FNMCustomGalleryCell.h"
#import "FinalPicture.h"
#import "FNMMyCollectionShareToolBar.h"
#import <QuartzCore/QuartzCore.h>
#import "VIFetchResultsDataSource.h"
#import "FNMFujifilmWebViewController.h"

#import "Constant.h"
#import "WebViewController.h"
#import "ASFBPostController.h"
#import "DETweetComposeViewController.h"
#import "UIImage+Resize.h"

#import <objc/runtime.h>
#import "FNMAPI_User.h"

@interface FNMMyCollectionViewController ()

@property (strong, nonatomic) FNMFinalPictureDataSource *dataSource;

@property (strong, nonatomic) UIImageView *topBar;
@property (strong, nonatomic) UIImageView *selectedImageView;
@property (strong, nonatomic) NSString *selectedClientName;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *backgroundImageView;
@property (strong, nonatomic) UIImageView *emptyCollectionView;
@property (strong, nonatomic) ODRefreshControl *refresh;

@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *hideShareButton;
@property (strong, nonatomic) UIButton *hideCurlButton;

@property (strong, nonatomic) FNMMyCollectionShareToolBar *shareToolbar;

@property (strong, nonatomic) WalgreensQPSDK *walgreensCheckoutContext;

@property (assign, nonatomic) BOOL isCurling;
@property (assign, nonatomic) BOOL isSharing;

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL loadingMorePages;

@end

@implementation FNMMyCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self structureBackground];
    [self createTable];
    [self setupPullToRefresh];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"cTimestamp" ascending:NO]];
    self.dataSource = [[FNMFinalPictureDataSource alloc] initWithPredicate:nil
                                                                 cacheName:nil
                                                                 tableView:self.tableView
                                                        sectionNameKeyPath:nil
                                                           sortDescriptors:sortDescriptors
                                                        managedObjectClass:[FinalPicture class]
                                                                 batchSize:20];
    self.dataSource.fetchedResultsController.delegate = self;

    self.selectedImageView = [[UIImageView alloc] initWithImage:nil];
    self.selectedImageView.frame = CGRectMake(15, 20, 290, 390);
    self.selectedImageView.center = CGPointMake(160, (screenHeight()-tabBarHeight())/2);
    self.selectedImageView.clipsToBounds = NO;
    [self.view addSubview:self.selectedImageView];

    [self setupShareButtons];
    [self.selectedImageView addSubview:self.shareButton];

    self.hideCurlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hideCurlButton setFrame:CGRectMake(self.selectedImageView.frame.origin.x,
                                             self.selectedImageView.frame.origin.y,
                                             self.selectedImageView.frame.size.width,
                                             self.selectedImageView.frame.size.height/2)];
    [self.hideCurlButton addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];

    self.shareToolbar = [[FNMMyCollectionShareToolBar alloc] initWithFrame:CGRectMake(6, 220, 290, 176)];
    self.shareToolbar.delegate = self;

    [self.backgroundImageView setFrame:self.selectedImageView.frame];
    self.backgroundImageView.backgroundColor = UIColorFromRGB(0x292929);
    [self.view insertSubview:self.backgroundImageView belowSubview:self.selectedImageView];
    self.backgroundImageView.alpha = 0.0f;
    self.backgroundImageView.clipsToBounds = YES;
    [self.backgroundImageView addSubview:self.shareToolbar];

    self.emptyCollectionView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    self.emptyCollectionView.image = [UIImage imageNamed:@"empty_collection_instructions_overlay.png"];
    self.emptyCollectionView.contentMode = UIViewContentModeCenter;
    self.emptyCollectionView.hidden = YES;
    [self.view insertSubview:self.emptyCollectionView belowSubview:self.tableView];
}

- (void)structureBackground
{
    self.topBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mycollection_screen_topbar"]];
    [self.topBar setFrame:CGRectMake(0, 0, 320, 34)];

    self.backgroundImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight())];

    self.currentDeletableID = @(0);

    UIImageView *baseBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Fanmento_Grey_Background"]];
    [baseBG setFrame:self.backgroundImageView.frame];
    [self.view addSubview:baseBG];
    [self.view addSubview:self.topBar];
}

- (void)setupShareButtons
{
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setImage:[UIImage imageNamed:@"share_corner_button"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.shareButton.frame = CGRectMake(232, 335, 60, 60);

    self.hideShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hideShareButton setImage:[UIImage imageNamed:@"FBDialog.bundle/images/close.png"] forState:UIControlStateNormal];
    [self.hideShareButton addTarget:self action:@selector(hideShareView) forControlEvents:UIControlEventTouchUpInside];
    [self.hideShareButton setFrame:CGRectMake(self.selectedImageView.frame.origin.x + self.selectedImageView.frame.size.width - (29/2) - 2,
                                              self.selectedImageView.frame.origin.y - (29/2) + 4,
                                              29,
                                              29)];
    [self.view addSubview:self.hideShareButton];
    self.hideShareButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.isVisible = YES;
    [self.tableView reloadData];
    self.emptyCollectionView.hidden = (self.dataSource.rowCount > 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self resetBackgroundFrame];
    [self fixCurlNotification];

    if (! self.isSharing) {
        self.backgroundImageView.frame = CGRectMake(0,0,320,screenHeight());

        if(self.shareScreenMode && self.selectedPicture != nil) {
            [self showShareView];
        } else {
            self.selectedImageView.alpha = 0.0f;
            self.tableView.alpha = 1.0f;
            [self.tableView reloadData];
        }
    } else {
        if (self.selectedPicture != nil && self.selectedImageView != nil) {
            [self.backgroundImageView setFrame:self.selectedImageView.frame];
            self.backgroundImageView.userInteractionEnabled = YES;
            self.selectedImageView.userInteractionEnabled = YES;
            self.view.userInteractionEnabled = YES;
            self.shareToolbar.userInteractionEnabled = YES;
            self.selectedImageView.image = self.selectedPicture;
        }
    }

    self.isSharing = NO;

    // If we haven't attempted to download the users collection from the servers, do so now
    BOOL myCollectionDownloaded = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_MY_COLLECTION_DOWNLOADED_KEY];
    if(! myCollectionDownloaded) {
        [self tableShouldRefresh:nil];
    }

    if(self.walgreensCheckoutContext == nil) {
        self.walgreensCheckoutContext = [[WalgreensQPSDK alloc] initWithAffliateId:WALGREENS_CHECKOUT_ACCESS_KEY
                                                                                 apiKey:WALGREENS_CHECKOUT_API_KEY
                                                                            environment:WALGREENS_ENVIRONMENT
                                                                             appVersion:WALGREENS_APP_VERSION
                                                                         ProductGroupID:WALGREENS_PRODUCT_GROUP_ID
                                                                            PublisherID:WALGREENS_PUBLISHER_ID
                                         success:nil failure:nil];
        self.walgreensCheckoutContext.delegate = self;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];

    if (! self.isSharing) {
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self hideShareView];
        self.shareScreenMode = NO;
        self.selectedPicture = nil;
        [self.selectedImageView.layer removeAllAnimations];
    } else {
        [self tap:nil];
    }
    self.isVisible = NO;
}

- (void)fixCurlNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fixCurl)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)fixCurl
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSelector:@selector(fixCurlNotification) withObject:nil afterDelay:1];
    if (self.shareButton.hidden && self.selectedImageView.alpha == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedImageView.image = self.selectedPicture;
            self.backgroundImageView.alpha = 1.0f;

            CATransition *animation = [CATransition animation];
            animation.delegate = self;
            animation.duration = 0.0f;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            animation.type = @"pageCurl";
            animation.fillMode = kCAFillModeForwards;
            animation.endProgress = 0.65;
            animation.removedOnCompletion = NO;
            [self.selectedImageView.layer addAnimation:animation forKey:@"pageCurlAnimation"];
            self.selectedImageView.image = nil;
            self.selectedImageView.userInteractionEnabled = NO;
            self.shareToolbar.userInteractionEnabled = YES;
            [self.view addSubview:self.hideCurlButton];
            [self performSelector:@selector(reenableAfterCurl) withObject:nil afterDelay:.7];
        });
    }
}

- (void)createTable
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 35.0, 320.0, screenHeight()-tabBarHeight()-35) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 200.0f;
    self.tableView.sectionFooterHeight = 10.0f;
    self.tableView.sectionHeaderHeight = 0.0f;
    [self.tableView registerNib:[UINib nibWithNibName:@"FNMCustomGalleryCell" bundle:nil] forCellReuseIdentifier:@"FNMCustomGalleryCell"];
    [self.view addSubview:self.tableView];

    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 34, 320, 20)];
    shadow.image = [UIImage imageNamed:@"shadow_top"];
    [self.topBar addSubview:shadow];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)reenableAfterCurl
{
    self.isCurling = NO;

    [self.view setUserInteractionEnabled:YES];
}

- (void)shareButtonClicked:(id)sender
{
    if (! self.isCurling) {
        self.view.userInteractionEnabled = NO;
        self.isCurling = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            DLog(@"SHARE BTN CLICK");
            self.shareToolbar.hidden = NO;
            // If the upload is still in process, disable the delete button until upload  is completed
            // setCurrentDeletableID will enable the button when we get the ID back from the server
            if(self.currentDeletableID == nil || [self.currentDeletableID isEqualToNumber:@(0)]) {
                [self.shareToolbar disableDeleteButton];
            }

            self.shareButton.hidden = YES;
            self.backgroundImageView.userInteractionEnabled = YES;
            self.backgroundImageView.alpha = 1.0f;
            [self.backgroundImageView bringSubviewToFront:self.shareToolbar];

            CATransition *animation = [CATransition animation];
            animation.delegate = self;
            animation.duration = 0.7;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            animation.type = @"pageCurl";
            animation.fillMode = kCAFillModeForwards;
            animation.endProgress = 0.65;
            animation.removedOnCompletion = NO;

            [self.selectedImageView.layer addAnimation:animation forKey:@"pageCurlAnimation"];
            self.selectedImageView.image = nil;
            self.selectedImageView.userInteractionEnabled = NO;
            self.shareToolbar.userInteractionEnabled = YES;
            [self.view addSubview:_hideCurlButton];
            [self performSelector:@selector(reenableAfterCurl) withObject:nil afterDelay:.7];
        });
    }
}

#pragma mark - TapGestureRecognizer

-(void)tap:(id)sender {

    if (! self.isCurling) {
        self.view.userInteractionEnabled = NO;
        self.isCurling = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedImageView.image = self.selectedPicture;
            CATransition *animation = [CATransition animation];
            animation.delegate = self;
            animation.duration = 0.7;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            animation.type = @"pageUnCurl";
            animation.fillMode = kCAFillModeForwards;
            animation.startProgress = 0.35;
            animation.removedOnCompletion = NO;

            [self.selectedImageView.layer addAnimation:animation forKey:@"pageUnCurlAnimation"];
            self.selectedImageView.userInteractionEnabled = YES;
            [self.hideCurlButton removeFromSuperview];

            self.shareButton.hidden = NO;
            self.backgroundImageView.userInteractionEnabled = NO;
            [self performSelector:@selector(reenableAfterCurl) withObject:nil afterDelay:.7];
        });
    }
}

#pragma mark - Pull To Refresh

- (void)setupPullToRefresh
{
    if (self.refresh == nil) {
        self.refresh = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [self.refresh setTintColor:[UIColor orangeColor]];
        [self.refresh setActivityIndicatorViewColor:[UIColor orangeColor]];
        [self.refresh addTarget:self action:@selector(tableShouldRefresh:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)disablePullToRefresh
{
    [self.refresh removeFromSuperview];
    self.refresh = nil;
}

- (void)tableShouldRefresh:(id)sender
{
    [self showHud];
    self.loadingMorePages = YES;
    self.currentPage = 0;
    [self getNextPageOfUserCollection];
}

- (void)getNextPageOfUserCollection
{
    self.currentPage++;
    [self disablePullToRefresh];

    [FNMAPI_User syncUserCollectionPage:self.currentPage completion:^(BOOL success, BOOL morePages) {
        self.loadingMorePages = morePages;
        [self endRefreshAndUpdateTable];
        if(success) {
            if(morePages) {
                [self getNextPageOfUserCollection];
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULTS_MY_COLLECTION_DOWNLOADED_KEY];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULTS_MY_COLLECTION_REFRESH_KEY];
                [self setupPullToRefresh];
            }
        } else {
            [[[FNMAlertView alloc] initWithTitle:@"Sync Error"
                                         message:@"We were unable to pull your collection from the server. Try again later."
                                        delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];
            [self setupPullToRefresh];
        }
    }];
}

- (void)endRefreshAndUpdateTable
{
    [self.tableView reloadData];
    [self.refresh endRefreshing];
    [self hideHud];
    self.emptyCollectionView.hidden = ([self.dataSource rowCount] > 0);
}

#pragma mark - FNMCustomGalleryCellDelegate

- (void)imageSelected:(UITapGestureRecognizer *)theTap
{
    self.selectedPicture = [(UIImageView*)theTap.view image];
    NSDictionary *test = objc_getAssociatedObject([(UIImageView*)theTap.view image], (const void*)0x314);
    self.currentDeletableID = [test objectForKey:PARAM_ID];

    if (self.detailViewBackground) {
        [self.detailViewBackground removeFromSuperview];
        self.detailViewBackground = nil;
    }

    id backgroundURL = [test objectForKey:@"background"];
    if (![[NSNull null] isEqual:backgroundURL] && backgroundURL != nil) {
        self.detailViewBackground = [[VILoaderImageView alloc]initWithFrame:CGRectMake(0, 0, 320, screenHeight())
                                                                   imageUrl:backgroundURL
                                                                   animated:YES];
    }

    self.shareScreenMode = YES;
    // These are only used immediately after the user creates a new image
    // They are not needed when a user selects an image from their collection
    self.selectedPictureEmail = nil;
    self.selectedPictureFacebook = nil;
    self.selectedPictureTwitter = nil;

    [self showShareView];
}

- (void)setCurrentDeletableID:(NSNumber *)currentDeletableID
{
    if ([currentDeletableID isKindOfClass:[NSNumber class]]) {
        _currentDeletableID = currentDeletableID;
        [self.shareToolbar enableDeleteButton];
    } else {
        DLog(@"Not a number!!!");
    }
}

- (void)resetBackgroundFrame
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.backgroundImageView setFrame:self.selectedImageView.frame];
    });

}
- (void)showShareView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.detailViewBackground) {
            [self.view insertSubview:self.detailViewBackground belowSubview:self.backgroundImageView];
            DLog(@"detail bg %@", [self.detailViewBackground description]);
            DLog(@"self.view subviews %@", [self.view.subviews description]);
        }
        self.topBar.alpha = 0.0f;
        self.tableView.alpha = 0.0f;
        self.selectedImageView.alpha = 1.0f;
        [self.shareToolbar setFrame:CGRectMake(6, 220, 290, 176)];
        self.hideShareButton.hidden = NO;
        self.selectedImageView.image = self.selectedPicture;
        self.selectedImageView.userInteractionEnabled = YES;
        [self.backgroundImageView setFrame:self.selectedImageView.frame];
        self.shareToolbar.hidden = YES;
    });

    self.backgroundImageView.alpha = 0.0f;

    self.shareToolbar.hidden = YES;
    self.shareButton.hidden = NO;

    [self performSelector:@selector(shareButtonClicked:) withObject:Nil afterDelay:.1];
    [self performSelector:@selector(tap:) withObject:Nil afterDelay:1.5];
}

- (void)hideShareView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.detailViewBackground) {
            [self.detailViewBackground removeFromSuperview];
            self.detailViewBackground = nil;
        }
        [self.hideCurlButton removeFromSuperview];
        self.topBar.alpha = 1.0f;
        self.hideShareButton.hidden = YES;
        self.backgroundImageView.alpha = 0.0f;
        self.selectedImageView.alpha = 0.0f;
        self.tableView.alpha = 1.0f;
        self.shareToolbar.hidden = YES;

        self.shareScreenMode = NO;
        self.selectedPicture = nil;
        [self.selectedImageView.layer removeAllAnimations];

        [self.tableView reloadData];
    });
}

#pragma mark - FNMMyCollectionShareToolBarDelegate

- (void)facebookSelected
{
    DLog(@"FACEBOOK BTN CLICK");
    self.isSharing = YES;
    FinalPicture *finalPicture = [FinalPicture getPictureWithID:self.currentDeletableID];
    [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Facebook Post Started"];
    ASFBPostController *fbPostController = [[ASFBPostController alloc] init];

    UIImage *tempImage = [self resizeImageForSharing:self.selectedPicture];
    fbPostController.thumbnailImage = tempImage;
    fbPostController.originalImage = tempImage;
    [fbPostController setDelegate:self];
    [fbPostController view];

    if (finalPicture.cFacebook.length > 2) {
        fbPostController.shareDefaulText = finalPicture.cFacebook;
    } else if(finalPicture == nil && self.shareScreenMode && self.selectedPictureFacebook.length > 0) {
        // If we just created a new picture and the upload process hasn't completed yet
        fbPostController.shareDefaulText = self.selectedPictureFacebook;
    }

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fbPostController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)emailSelected
{
    if ([MFMailComposeViewController canSendMail]) {
        DLog(@"EMAIL BTN CLICK");
        self.isSharing = YES;

        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        FinalPicture *finalPicture = [FinalPicture getPictureWithID:self.currentDeletableID];

        if (finalPicture.cEmail.length > 2) {
            [controller setMessageBody:finalPicture.cEmail isHTML:NO];
        } else if(finalPicture == nil && self.shareScreenMode && self.selectedPictureEmail.length > 0) {
            // If we just created a new picture and the upload process hasn't completed yet
            [controller setMessageBody:self.selectedPictureEmail isHTML:NO];
        } else {
            [controller setMessageBody:@"Check out my Fanmento photo! Download Fanmento & Create your personalized fan photo!: http://fanmento.com" isHTML:NO];
        }


        [controller setSubject:@"Check out my personalized photo from Fanmento!"];
        controller.mailComposeDelegate = self;
        UIImage *tempImage = [self resizeImageForSharing:self.selectedPicture];
        NSData *myData = UIImagePNGRepresentation(tempImage);
        [controller addAttachmentData:myData mimeType:@"image/png" fileName:@"myfanmento.png"];

        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [[[FNMAlertView alloc] initWithTitle:@"No Email"
                                     message:@"This device does not have an email account set up."
                                    delegate:nil
                           cancelButtonTitle:@"Okay"
                           otherButtonTitles:nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent) {
        [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Photo Email Sent"];
    } else if (result == MFMailComposeResultSaved){
        [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Photo Email Draft Saved"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)twitterSelected
{
    DLog(@"TWITTER BTN CLICK");
    self.isSharing = YES;
    DETweetComposeViewController *tcvc = [[DETweetComposeViewController alloc] init];
    [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Twitter Post Started"];
    FinalPicture *finalPicture = [FinalPicture getPictureWithID:self.currentDeletableID];

    UIImage *tempImage = [self resizeImageForSharing:self.selectedPicture];
    [tcvc addImage:tempImage];
    [tcvc setDelegate:self];

    if (finalPicture.cTwitter.length > 2) {
        [tcvc setInitialText:finalPicture.cTwitter];
    } else if(finalPicture == nil && self.shareScreenMode && self.selectedPictureTwitter.length > 0) {
        // If we just created a new picture and the upload process hasn't completed yet
        [tcvc setInitialText:self.selectedPictureTwitter];
    } else {
        [tcvc setInitialText:@"Check out my @Fanmento photo!"];
    }

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:tcvc animated:YES completion:nil];
}

- (void)showHud
{
    [[FNMAppDelegate appDelegate] disableTabBar];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideHud
{
    [[FNMAppDelegate appDelegate] enableTabBar];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)shopSelected
{
    FinalPicture *finalPicture = [FinalPicture getPictureWithID:self.currentDeletableID];
    self.selectedClientName = finalPicture.cClientName;
    [[[UIActionSheet alloc] initWithTitle:@"Order photo prints for"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Home Delivery", @"Store Pickup", nil]
     showInView:[FNMAppDelegate appDelegate].tabBarController.view];
}

- (void)goToWalgreensCheckout
{
    if(isUSDevice()){
        if (self.walgreensCheckoutContext) {
            self.isSharing = YES;
            DLog(@"SHOP BTN CLICK");
            [self showHud];
            [self.hud setMode:MBProgressHUDModeDeterminate];
            self.hud.labelText = @"Uploading images...";
            [self.walgreensCheckoutContext clearImageQueue];
            [self.walgreensCheckoutContext setAffNotes:@""];
            if(self.selectedClientName.length > 0) {
                [self.walgreensCheckoutContext setAffNotes:self.selectedClientName];
            }
            [self.walgreensCheckoutContext upload:UIImageJPEGRepresentation(self.selectedPicture, 1.0) progressBlock:nil successBlock:nil failureBlock:nil];
        } else {
            [[[FNMAlertView alloc] initWithTitle:@"Unavailable"
                                         message:@"Unable to connect to Walgreens Checkout, return to this view later to retry"
                                        delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];
        }
    } else {
        [[[FNMAlertView alloc] initWithTitle:@"Unavailable"
                                     message:WAG_OUTSIDE_US
                                    delegate:nil
                           cancelButtonTitle:@"Okay"
                           otherButtonTitles:nil] show];
    }
}

#pragma mark - Delete

- (void)deleteSelected
{
    [[[FNMAlertView alloc] initWithTitle:@"Delete?"
                                 message:@"Are you sure you'd like to delete this photo?"
                                delegate:self
                       cancelButtonTitle:@"No"
                       otherButtonTitles:@"Yes", nil] show];
}

- (void)alertView:(FNMAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self finishDelete];
    }
}

- (void)finishDelete
{
    [self showHud];
    self.hud.labelText = @"Deleting...";
    [[FNMAppDelegate appDelegate] disableTabBar];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([FinalPicture deleteCreatedPicture:nil withKey:self.currentDeletableID]) {
            NSManagedObjectContext *context = [[VICoreDataManager getInstance] startTransaction];

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", self.currentDeletableID];

            FinalPicture *finalPicture = [FinalPicture fetchForPredicate:predicate forManagedObjectContext:context];
            [[VICoreDataManager getInstance] deleteObject:finalPicture];
            [[VICoreDataManager getInstance] endTransactionForContext:context];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [[FNMAppDelegate appDelegate] enableTabBar];
                [self tap:nil];
                [self performSelector:@selector(hideShareView) withObject:nil afterDelay:1.5];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [[FNMAppDelegate appDelegate] enableTabBar];
            });
            [[[FNMAlertView alloc] initWithTitle:@"Delete Error"
                                         message:@"Unable to delete, possibly due to low signal. Please try again later."
                                        delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];
        }
    });
}

#pragma mark - Walgreens Checkout Delegate
// INIT
/**
 * ... This will be called when the authentication is success ...
 */
- (void)initSuccessResponse:(NSString*)response
{
    DLog(@"WAG: Succesful Authentication: %@", response);
}

/**
 * ... This will be called when the authentication is failure ...
 */

- (void)didInitFailWithError:(NSError *)error
{
    DLog(@"WAG: Failed Authentication: %@", error.localizedDescription);
}

//The SDK says that this method is optional, but they must not be doing proper checking, because the SDK crashed the app trying to call this method a few times
//Putting it in as a catch, instead of trying to fix Walgreens SDK.
- (void)initErrorResponse:(NSString*)response
{
    DLog(@"%@", response);
    self.walgreensCheckoutContext = nil;
}

//IMAGE UPLOAD
/**
 * ... This will be called when the image upload process is success ...
 */


// New delegate methods support both single and multiple image upload
- (void)imageuploadSuccessWithImageData:(WAGImageData *)imageData
{
    DLog(@"WAG: Succesful Image Upload");
    
    //Block for success response
    void (^successBlock)(NSString *) = ^(NSString *responseString)
    {
        [self cartPosterSuccessResponse:responseString];
    };
    
    //Block for Failure response
    void (^faiureBlock)(NSError *) = ^(NSError *errorObject)
    {
        [self didCartPostFailWithError:errorObject];
    };
    
    self.hud.labelText = @"Upload Successful";
    [self.walgreensCheckoutContext postCart:successBlock failure:faiureBlock];
}

- (void)imageuploadErrorWithImageData:(WAGImageData *)imageData  Error:(NSError *)error
{
    DLog(@"WAG: Failed Image Upload");
    self.hud.labelText = @"Walgreens: Image Upload Failed";

    [self hideHud];

    [[[FNMAlertView alloc] initWithTitle:@"Upload Error"
                                 message:@"Image upload failed, possibly due to low signal. Please try again later."
                                delegate:nil
                       cancelButtonTitle:@"Okay"
                       otherButtonTitles:nil] show];
}

/**
 * ... This will give the upload pregress status ...
 */
- (void)getUploadProgress:(float)progress
{
    DLog(@"WAG: Upload Progress: %f", progress);
    [self.hud setProgress:progress];
}

//CART POSTER
/**
 * ... This will be called when the cartPoster returns url ...
 */
- (void)cartPosterSuccessResponse:(NSString*)response
{
    DLog(@"WAG: Succesful Cart Poster: %@", response);
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController"
                                                                               bundle:nil];
    [webViewController view];
    webViewController.closeButton.hidden = YES;
    webViewController.webTitle = @"Order Prints";
    [webViewController hideToolbar];
    [webViewController loadPageWithUrl:[NSURL URLWithString:response]];
    [self presentViewController:webViewController animated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Single Walgreens Photo"];
            [self hideHud];
        });
    }];
}

/**
 * ... This will be called when the cartPoster process is failure ...
 */
- (void)didCartPostFailWithError:(NSError *)error
{
    DLog(@"WAG: Cart Post Failed With Error: %@", error.localizedDescription);
    [self hideHud];
    [[[FNMAlertView alloc] initWithTitle:@"Upload Error"
                                 message:@"Image upload failed, possibly due to low signal. Please try again later."
                                delegate:nil
                       cancelButtonTitle:@"Okay"
                       otherButtonTitles:nil] show];
}

- (void)cartPosterErrorResponse:(NSString*)response
{
    DLog(@"WAG: Error Cart Poster: %@", response);
    [self hideHud];

    [[[FNMAlertView alloc] initWithTitle:@"Upload Error"
                                 message:@"Image upload failed, possibly due to low signal. Please try again later."
                                delegate:nil
                       cancelButtonTitle:@"Okay"
                       otherButtonTitles:nil] show];
}

- (void)didFinishBatch
{
    DLog(@"WAG: Did Finish Batch");
}


// EXCEPTION
/**
 * ... This will be called when there is any generic exception ...
 */

- (void)didServiceFailWithError:(NSError*)error
{
    DLog(@"WAG: Service Fail With Error: %@", error.localizedDescription);
    [[[FNMAlertView alloc] initWithTitle:@"Upload Error"
                                 message:@"Image upload failed, possibly due to low signal. Please try again later."
                                delegate:nil
                       cancelButtonTitle:@"Okay"
                       otherButtonTitles:nil] show];
}

#pragma mark - Fuji Checkout

- (void)goToFujiCheckout
{
    self.isSharing = YES;
    self.hud.mode = MBProgressHUDModeDeterminate;
    self.hud.labelText = @"Uploading images...";
    [self showHud];

    FFImage *ffImage = [[FFImage alloc] init];
    ffImage.image = self.selectedPicture;
    if(self.selectedClientName.length > 0) {
        ffImage.properties = @{FUJI_TEMPLATE_NAME_KEY: self.selectedClientName};
    }

    FNMFujifilmWebViewController *fujifilmWebViewController = [[FNMFujifilmWebViewController alloc] init];
    [fujifilmWebViewController checkOut:@[ffImage]
                            productCode:@""
                       cacheAddressInfo:YES
                                 userID:nil];

    // Per Fuji, the fujifilmWebViewControlller class does not handle being displayed in a modal well.
    // It need's to be displayed in a navigation controller, but we will simulate the modal animation,
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fujifilmWebViewController];
    navController.navigationBarHidden = YES;
    navController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController
                       animated:YES
                     completion:^{
                         [self hideHud];
                     }];
}

- (UIImage *)resizeImageForSharing:(UIImage *)image
{
    return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                       bounds:CGSizeMake(320,image.size.height)
                         interpolationQuality:kCGInterpolationMedium];
}


#pragma mark - NSFetchResutlsControllerDelegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.emptyCollectionView.hidden = (controller.fetchedObjects.count > 0);
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self goToFujiCheckout];
    } else if(buttonIndex == 1) {
        [self goToWalgreensCheckout];
    }
}

@end
