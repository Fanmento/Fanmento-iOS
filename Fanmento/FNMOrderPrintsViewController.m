//
//  FNMOrderPrintsViewController.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/29/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "FNMOrderPrintsViewController.h"
#import "FNMAPI_User.h"
#import "FNMAppDelegate.h"
#import "FinalPicture.h"
#import "MBProgressHUD.h"
#import "WebViewController.h"
#import "Constant.h"
#import "SDWebImageManager.h"
#import "FNMFujifilmWebViewController.h"

@interface FNMOrderPrintsViewController ()

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableArray *imagesToUpload;
@property (strong, nonatomic) NSMutableArray *clientNamesToUpload;
@property (strong, nonatomic) UIImageView *emptyCollectionView;

@property (strong, nonatomic) FNMFinalPictureDataSource *dataSource;
@property (strong, nonatomic) UIImageView *topBar;
@property (strong, nonatomic) JPImagePickerController *imagePickerController;

@property (assign, nonatomic) NSInteger totalImages;
@property (assign, nonatomic) NSInteger assetsUploaded;

@property (strong, nonatomic) WalgreensQPSDK *walgreensCheckoutContext;
@property (strong, nonatomic) NSMutableString *walgreensAffiliateNotes;

@property (assign, nonatomic) NSInteger currentPage;

@end

@implementation FNMOrderPrintsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *baseBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Fanmento_Grey_Background"]];
    baseBG.frame = CGRectMake(0, 0, 320, screenHeight());
    [self.view addSubview:baseBG];

    self.topBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopping-screen_topbar"]];
    self.topBar.frame = CGRectMake(0, 0, 320, 34);
    [self.view addSubview:self.topBar];

    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 34, 320, 20)];
    shadow.image = [UIImage imageNamed:@"shadow_top"];
    [self.view addSubview:shadow];

    UIButton *orderPrintsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    orderPrintsButton.frame = CGRectMake(260, 2, 50, 30);
    [orderPrintsButton setImage:[UIImage imageNamed:@"order_prints_button"] forState:UIControlStateNormal];
    [orderPrintsButton addTarget:self action:@selector(selectPrintProvider) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:orderPrintsButton];

    [self setupImagePicker];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setEmptyCollectionViewVisibility)
                                                 name:@"PhotoPickerControllerLoadComplete"
                                               object:nil];

    self.emptyCollectionView = [[UIImageView alloc] initWithFrame:baseBG.frame];
    self.emptyCollectionView.image = [UIImage imageNamed:@"empty_order-prints_instructions_overlay.png"];
    self.emptyCollectionView.contentMode = UIViewContentModeCenter;
    self.emptyCollectionView.hidden = self.dataSource.fetchedResultsController.fetchedObjects.count;
    [self.view insertSubview:self.emptyCollectionView belowSubview:self.imagePickerController.view];
    [self setEmptyCollectionViewVisibility];

    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:self.hud];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.imagePickerController.overviewController.scrollView setContentOffset:CGPointZero animated:NO];
    [self.hud hide:YES];
    [self.imagePickerController reloadInputViews];

    // If the user hasn't gone to My Collection yet, but has images on the server, download them here
    BOOL myCollectionDownloaded = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_MY_COLLECTION_DOWNLOADED_KEY];
    if(! myCollectionDownloaded) {
        [self downloadMyCollection];
    }
    
    //Block for success response
    void (^successBlock)(NSString *) = ^(NSString *responseString)
    {
        [self initSuccessResponse:responseString];
    };
    
    //Block for Failure response
    void (^faiureBlock)(NSError *) = ^(NSError *errorObject)
    {
        [self didInitFailWithError:errorObject];
    };

    if(self.walgreensCheckoutContext == nil) {
        self.walgreensCheckoutContext = [[WalgreensQPSDK alloc] initWithAffliateId:WALGREENS_CHECKOUT_ACCESS_KEY
                                                                                 apiKey:WALGREENS_CHECKOUT_API_KEY
                                                                            environment:WALGREENS_ENVIRONMENT
                                                                             appVersion:WALGREENS_APP_VERSION
                                                                         ProductGroupID:WALGREENS_PRODUCT_GROUP_ID
                                                                            PublisherID:WALGREENS_PUBLISHER_ID
                                         success:successBlock failure:faiureBlock];
        self.walgreensCheckoutContext.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.hud hide:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)selectPrintProvider
{
    self.hud.labelText = @"Uploading photos...";
    [[[UIActionSheet alloc] initWithTitle:@"Order photo prints for"
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Home Delivery", @"Store Pickup", nil]
     showInView:[FNMAppDelegate appDelegate].tabBarController.view];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark - JPImagePickerControllerDelegate

- (void)setupImagePicker
{
    self.imagePickerController = [[JPImagePickerController alloc] init];
    self.imagePickerController.navigationController.navigationBarHidden = YES;
    self.imagePickerController.delegate = self;

    [self addChildViewController:self.imagePickerController];
    [self.view insertSubview:self.imagePickerController.view belowSubview:self.topBar];

    [self setupDataSource];
}

- (void)setupDataSource
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"cTimestamp" ascending:NO]];

    self.dataSource = [[FNMFinalPictureDataSource alloc] initWithPredicate:nil
                                                                 cacheName:nil
                                                                 tableView:nil
                                                        sectionNameKeyPath:nil
                                                           sortDescriptors:sortDescriptors
                                                        managedObjectClass:[FinalPicture class]];

    [self.dataSource addObserver:self forKeyPath:@"items" options:0 context:NULL];

    self.dataSource.fetchedResultsController.delegate = self;
    self.imagePickerController.dataSource = self.dataSource;
}

- (void)removeImagePicker
{
    self.imagePickerController.dataSource = nil;
    self.imagePickerController.delegate = nil;
    [self.imagePickerController removeFromParentViewController];
    [self.imagePickerController.view removeFromSuperview];
    self.imagePickerController = nil;

    [self.dataSource removeObserver:self forKeyPath:@"items"];
    self.dataSource = nil;
}

- (void)downloadMyCollection
{
    [self removeImagePicker];

    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Loading...";
    [self.hud show:YES];

    self.currentPage = 0;
    [self getNextPageOfUserCollection];
}

- (void)getNextPageOfUserCollection
{
    self.currentPage++;
    [FNMAPI_User syncUserCollectionPage:self.currentPage completion:^(BOOL success, BOOL morePages) {
        if(success) {
            if(morePages) {
                [self getNextPageOfUserCollection];
            } else {
                [self finishedDownloadingMyCollection];
            }
        } else {
            [[[FNMAlertView alloc] initWithTitle:@"Sync Error"
                                         message:@"We were unable to pull your collection from the server. Try again later."
                                        delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];
        }
    }];
}

- (void)finishedDownloadingMyCollection
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULTS_MY_COLLECTION_DOWNLOADED_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULTS_MY_COLLECTION_REFRESH_KEY];

    [self.hud hide:YES];
    self.hud.mode = MBProgressHUDModeDeterminate;
    self.hud.labelText = @"Uploading photos...";

    [self setupImagePicker];
}

#pragma mark - Walgreens Checkout

- (void)goToWalgreensCheckout
{
    if (isUSDevice()) {
        if(self.walgreensCheckoutContext) {
            [self.walgreensCheckoutContext clearImageQueue];
            [self.walgreensCheckoutContext setAffNotes:@""];

            NSArray *imageNumbers = [self.imagePickerController.overviewController.multiImageArray mutableCopy];

            if (imageNumbers.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.hud.detailsLabelText = [NSString stringWithFormat:@"Grabbing Image 1 of %i", (int)self.totalImages];
                    [self.hud setMode:MBProgressHUDModeDeterminate];
                    [self.hud show:YES];
                    [[FNMAppDelegate appDelegate] disableTabBar];
                });

                self.totalImages = imageNumbers.count;
                self.assetsUploaded = 0;

                self.imagesToUpload = [[NSMutableArray alloc] init];
                self.walgreensAffiliateNotes = [[NSMutableString alloc] init];

                __block NSInteger imageBeingGrabbed = 1;
                __block NSInteger imagesNeedingDownloaded = 0;
                __block BOOL anyFailures = NO;

                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                for (NSNumber *index in imageNumbers) {
                    id imageToUpload = [self.dataSource imagePicker:self.imagePickerController imageForImageNumber:index.intValue];
                    NSString *clientName = [self.dataSource clientNameForImageNumber:index.intValue];
                    if(clientName && clientName.length > 0) {
                        if(self.walgreensAffiliateNotes.length > 0) {
                            [self.walgreensAffiliateNotes appendString:@","];
                        }
                        [self.walgreensAffiliateNotes appendString:clientName];
                    }

                    if ([imageToUpload isKindOfClass:[UIImage class]]) {
                        imageBeingGrabbed++;
                        [self.imagesToUpload addObject:UIImageJPEGRepresentation([self.dataSource imagePicker:self.imagePickerController imageForImageNumber:index.intValue], 1.0)];
                    } else {
                        imagesNeedingDownloaded++;

                        [manager downloadImageWithURL:imageToUpload
                                         options:0
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize)
                         {
                             CGFloat receivedSizeFloat = receivedSize;
                             CGFloat percent = expectedSize/receivedSizeFloat;

                             [self.hud setProgress:percent];
                         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url) {
                             imageBeingGrabbed++;
                             if (image && finished) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     self.hud.detailsLabelText = [NSString stringWithFormat:@"Grabbing Image %i of %i", (int)imageBeingGrabbed, (int)self.totalImages];
                                 });

                                 [self.imagesToUpload addObject:UIImageJPEGRepresentation(image, 1.0)];
                             } else {
                                 anyFailures = YES;
                             }

                             if (imageBeingGrabbed > self.totalImages) {
                                 [self attemptUploadToCartWithFailures:anyFailures];
                             }
                         }];
                    }
                }

                if (imagesNeedingDownloaded == 0) {
                    [self attemptUploadToCartWithFailures:NO];
                }
            } else {
                [[[FNMAlertView alloc] initWithTitle:@"No Pictures Selected"
                                             message:@"You first have to select a picture to print by tapping an image in the grid."
                                            delegate:nil
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil] show];
            }
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

- (void)attemptUploadToCartWithFailures:(BOOL)anyFailures
{
    DLog(@"Upload Attempted");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!anyFailures) {
            self.hud.detailsLabelText = @"Uploading Images";
            self.hud.progress = 0.0f;
            self.hud.mode = MBProgressHUDModeDeterminate;

            NSLog(@"Currently have %d items in imagesToUpload", (int)self.imagesToUpload.count);
            [self.walgreensCheckoutContext upload:[self.imagesToUpload objectAtIndex:0] progressBlock:nil successBlock:nil failureBlock:nil];
        } else {
            [[FNMAppDelegate appDelegate] enableTabBar];
            [self.hud hide:YES];
            [[[FNMAlertView alloc] initWithTitle:@"Error"
                                         message:@"There was a connection error trying to get your image, please try again"
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
-(void)initSuccessResponse:(NSString*)response
{
    DLog(@"WAG: Succesful Authentication: %@", response);
}

/**
 * ... This will be called when the authentication is failure ...
 */
-(void)didInitFailWithError:(NSError *)error
{
    DLog(@"WAG: Failed Authentication: %@", error.localizedDescription);
    self.walgreensCheckoutContext = nil;
}

//The SDK says that this method is optional, but they must not be doing proper checking, because the SDK crashed the app trying to call this method a few times
//Putting it in as a catch, instead of trying to fix Walgreens SDK.
-(void)initErrorResponse:(NSString*)response
{
    DLog(@"%@", response);
}

//IMAGE UPLOAD
/**
 * ... This will be called when the image upload process is success ...
 */

// New delegate methods support both single and multiple image upload
-(void)imageuploadSuccessWithImageData:(WAGImageData *)imageData
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

    self.assetsUploaded++;
    [self.imagesToUpload removeObjectAtIndex:0];
    if (self.imagesToUpload.count == 0) {
        self.assetsUploaded = 0;
        self.totalImages = 0;
        [self.imagesToUpload removeAllObjects];
        self.imagesToUpload = [[NSMutableArray alloc] init];
        self.hud.detailsLabelText = @"";
        self.hud.labelText = @"Upload Successful";
        if(self.walgreensAffiliateNotes.length > 0) {
            [self.walgreensCheckoutContext setAffNotes:self.walgreensAffiliateNotes];
        }
        [self.walgreensCheckoutContext postCart:successBlock failure:faiureBlock];
    } else {
        [self.walgreensCheckoutContext upload:[self.imagesToUpload objectAtIndex:0] progressBlock:nil successBlock:nil failureBlock:nil];
    }
}

-(void)imageuploadErrorWithImageData:(WAGImageData *)imageData  Error:(NSError *)error
{
    DLog(@"WAG: Failed Image Upload %@", [error description]);
    self.hud.detailsLabelText = @"";
    self.hud.labelText = @"Image Upload Failed";
    [self.hud hide:YES afterDelay:2];
    [[FNMAppDelegate appDelegate] enableTabBar];
}

/**
 * ... This will give the upload pregress status ...
 */
-(void)getUploadProgress:(float)progress
{
    self.hud.progress = (progress / self.totalImages) + (self.assetsUploaded * 1.0 / self.totalImages);
}

//CART POSTER
/**
 * ... This will be called when the cartPoster returns url ...
 */
-(void)cartPosterSuccessResponse:(NSString*)response
{
    DLog(@"WAG: Succesful Cart Poster: %@", response);
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController"
                                                                               bundle:nil];
    [webViewController view];
    webViewController.closeButton.hidden = YES;
    webViewController.webTitle = @"Order Prints";
    [webViewController hideToolbar];
    [webViewController loadPageWithUrl:[NSURL URLWithString:response]];
    [self presentViewController:webViewController animated:TRUE completion:^{
        [self.imagePickerController.overviewController.multiImageArray removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FNMAppDelegate appDelegate] trackPageViewWithName:@"Multiple Walgreens Photos"];
            [self.hud hide:YES];
            [[FNMAppDelegate appDelegate] enableTabBar];
        });
    }];
}

/**
 * ... This will be called when the cartPoster process is failure ...
 */
-(void)didCartPostFailWithError:(NSError *)error
{
    DLog(@"WAG: Cart Post Failed With Error: %@", error.localizedDescription);
    [self.hud setLabelText:@"Cart Upload Failed"];
    [self.hud hide:YES afterDelay:2];
    [[FNMAppDelegate appDelegate] enableTabBar];
}

-(void)cartPosterErrorResponse:(NSString*)response
{
    DLog(@"WAG: Error Cart Poster: %@", response);
    [self.hud setLabelText:@"Cart Upload Failed"];
    [self.hud hide:YES afterDelay:2];
    [[FNMAppDelegate appDelegate] enableTabBar];
}

-(void)didFinishBatch
{
    DLog(@"WAG: Did Finish Batch");
}

// EXCEPTION
/**
 * ... This will be called when there is any generic exception ...
 */

-(void)didServiceFailWithError:(NSError*)error
{
    [self.hud setLabelText:@"Walgreens Upload Failed"];
    [self.hud hide:YES afterDelay:2];
    DLog(@"WAG: Service Fail With Error: %@", error.localizedDescription);
}

#pragma mark - Fuji Checkout

- (void)goToFujiCheckout
{
    NSArray *imageNumbers = self.imagePickerController.overviewController.multiImageArray;

    if (imageNumbers.count > 0) {
        self.hud.detailsLabelText = [NSString stringWithFormat:@"Grabbing Image 1 of %i", (int)imageNumbers.count];
        self.hud.mode = MBProgressHUDModeDeterminate;
        [self.hud show:YES];
        [[FNMAppDelegate appDelegate] disableTabBar];

        self.imagesToUpload = [[NSMutableArray alloc] init];
        self.clientNamesToUpload = [[NSMutableArray alloc] init];

        __block NSInteger imageBeingGrabbed = 1;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];

        for (NSNumber *index in imageNumbers) {
            id imageToUpload = [self.dataSource imagePicker:self.imagePickerController imageForImageNumber:index.intValue];
            [self.clientNamesToUpload addObject:[self.dataSource clientNameForImageNumber:index.intValue]];

            if ([imageToUpload isKindOfClass:[UIImage class]]) {
                imageBeingGrabbed++;

                [self.imagesToUpload addObject:imageToUpload];

                if(self.imagesToUpload.count == imageNumbers.count) {
                    [self displayFujiCheckout];
                }
            } else {
                [manager downloadImageWithURL:imageToUpload
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    CGFloat receivedSizeFloat = receivedSize;
                                    CGFloat percent = expectedSize / receivedSizeFloat;

                                    [self.hud setProgress:percent];
                                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url) {
                                    imageBeingGrabbed++;
                                    if (image && finished) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.imagesToUpload addObject:image];

                                            if(self.imagesToUpload.count == imageNumbers.count) {
                                                [self displayFujiCheckout];
                                            } else {
                                                self.hud.detailsLabelText = [NSString stringWithFormat:@"Grabbing Image %i of %i", (int)imageBeingGrabbed, (int)imageNumbers.count];
                                            }
                                        });
                                    }
                                }];
            }
        }
    } else {
        [[[FNMAlertView alloc] initWithTitle:@"No Pictures Selected"
                                     message:@"You first have to select a picture to print by tapping an image in the grid."
                                    delegate:nil
                           cancelButtonTitle:@"Okay"
                           otherButtonTitles:nil] show];
    }
}

- (void)displayFujiCheckout
{
    NSMutableArray *fujiImagesArray = [[NSMutableArray alloc] init];
    for (int imageNumber = 0; imageNumber < self.imagesToUpload.count; imageNumber++) {
        FFImage *ffImage = [[FFImage alloc] init];
        ffImage.image = self.imagesToUpload[imageNumber];
        ffImage.properties = @{FUJI_TEMPLATE_NAME_KEY: self.clientNamesToUpload[imageNumber]};
        [fujiImagesArray addObject:ffImage];
    }

    FNMFujifilmWebViewController *fujifilmWebViewController = [[FNMFujifilmWebViewController alloc] init];
    [fujifilmWebViewController checkOut:fujiImagesArray
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
                         [self.hud hide:YES];
                         [[FNMAppDelegate appDelegate] enableTabBar];
                     }];
}

#pragma mark - NSFetchResutlsControllerDelegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self setEmptyCollectionViewVisibility];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self setEmptyCollectionViewVisibility];
}

- (void)setEmptyCollectionViewVisibility
{
    self.emptyCollectionView.hidden =
            [((FNMFinalPictureDataSource *)self.imagePickerController.dataSource)
                    numberOfImagesInImagePicker:self.imagePickerController] > 0;
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
