//
//  FNMGalleryDetailViewController.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/31/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryDetailViewController.h"
#import "FinalPicture.h"
#import "FNMMyCollectionViewController.h"
#import "FNMGalleryViewController.h"
#import "FNMAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "VILoaderImageView.h"
#import "APIConstants.h"
#import "FNMGalleryDetailViewController+Filters.h"
#import "UIImageView+WebCache.h"
#import "WebViewController.h"
#import "FNMAdvertisement.h"

#define TAG_FLASH_MODE 11

@interface FNMGalleryDetailViewController ()

@property(strong, nonatomic) UIView* renderView;
@property(strong, nonatomic) UIImage* finalImage;
@property(strong, nonatomic) UIImagePickerController* imagePickerController;
@property(strong, nonatomic) UIImageView* templateImageView; //holds the template/gallery image
@property(strong, nonatomic) UIImageView* chosenImageView; //holds the image taken or chosen by the user
@property(strong, nonatomic) UIImageView* watermarkImageView;
@property(strong, nonatomic) VILoaderImageView* advertImageView;
@property(strong, nonatomic) FNMGalleryDetailTabBar* tabBar;
@property(strong, nonatomic) FNMGalleryScaleRotateTabBar* scaleRotateTabBar;
@property(strong, nonatomic) WebViewController* webViewController;

@property(nonatomic) BOOL cameraChosen;
@property(strong, atomic) UIButton* advertButton;
@property(nonatomic) BOOL pictureSelected;

@property(strong, nonatomic) UIButton *hideTutButton;
@property(strong, nonatomic) UIImageView *tutImage;

@end

@implementation FNMGalleryDetailViewController

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setTemplateImage:image];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.selectedTemplate == nil) {
        self.templateImageView = [[UIImageView alloc] initWithImage:(UIImage*)self.templateImage];
        self.templateImageView.frame = CGRectMake(0,-2,320,414);
    }else{
        self.templateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,-2,320,414)];
        [self.templateImageView setImageWithURL:[NSString stringWithFormat:@"%@=s863",self.selectedTemplate.cRemoteURL]];
    }
    
    self.watermarkImageView = [[UIImageView alloc] initWithFrame:self.templateImageView.frame];
    [self.watermarkImageView setImage:[UIImage imageNamed:@"watermark.png"]];
    
    self.tabBar = [[FNMGalleryDetailTabBar alloc] initWithFrame:CGRectMake(0, 406, 320, 54)];
    self.tabBar.delegate = self;
    if (self.selectedTemplate) {
        [self.tabBar setTemplateImage:self.selectedTemplate.cRemoteURL];
    }else{
        [self.tabBar setTemplateImage:self.templateImage];
    }
    
    self.tabBar.frame = CGRectMake(0, 0, 320, screenHeight());
    
    self.tabBar.torchModeButton = [[DDExpandableButton alloc] initWithPoint:CGPointMake(8.0f, 8.0f)
                                                                  leftTitle:[UIImage imageNamed:@"Flash.png"]
                                                                    buttons:[NSArray arrayWithObjects:@"Off", @"Auto", @"On", nil]];

	[(UIView*)self.tabBar addSubview:self.tabBar.torchModeButton];
	[self.tabBar.torchModeButton addTarget:self action:@selector(flashModeSelected:) forControlEvents:UIControlEventValueChanged];
	[self.tabBar.torchModeButton setVerticalPadding:6];
	[self.tabBar.torchModeButton updateDisplay];
	[self.tabBar.torchModeButton setSelectedItem:1];
    
    [self initImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
    
    self.scaleRotateTabBar = [[FNMGalleryScaleRotateTabBar alloc] initWithFrame:CGRectMake(0, screenHeight()-54, 320, 54)];
    self.scaleRotateTabBar.delegate = self;
    
    NSString *thePathAdvert = [[NSBundle mainBundle] pathForResource:@"template_ad" ofType:@"png"];
    UIImage *advertImage = [[UIImage alloc] initWithContentsOfFile:thePathAdvert];
    if (self.selectedTemplate) {
        if (self.selectedTemplate.cAdURL.length > 1) {
            self.advertImageView = [[VILoaderImageView alloc]initWithFrame:self.view.frame imageUrl:self.selectedTemplate.cAdURL];
            if (self.selectedTemplate.cAdTarget.length > 1) {
                UITapGestureRecognizer*adLink = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(adLinkClicked:)];
                [adLink setNumberOfTapsRequired:1];
                [adLink setNumberOfTouchesRequired:1];
                [adLink setDelegate:self];
                [self.advertImageView addGestureRecognizer:adLink];
            }
        }else{
            self.advertImageView = [[VILoaderImageView alloc] initWithImage:advertImage];
        }
    }else{
        self.advertImageView = [[VILoaderImageView alloc] initWithImage:advertImage];
    }

    self.advertButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [self.advertButton setImage:[UIImage imageNamed:@"FBDialog.bundle/images/close.png"] forState:UIControlStateNormal];
    [self.advertButton addTarget:self action:@selector(advertButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.advertButton.frame = CGRectMake(276, 15, 29, 29);
    self.advertButton.frame = CGRectInset(self.advertButton.frame, -40, -40);
    [self.advertButton.imageView setContentMode:UIViewContentModeCenter];
    [self.advertImageView setUserInteractionEnabled:YES];

    self.cameraChosen = FALSE;
    self.pictureSelected = FALSE;
    
    self.chosenImageView = [[UIImageView alloc] init];

    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [self.chosenImageView addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [self.chosenImageView addGestureRecognizer:rotationRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.chosenImageView addGestureRecognizer:panRecognizer];
    
    [self.templateImageView setUserInteractionEnabled:NO];
    [self.watermarkImageView setUserInteractionEnabled:NO];
    [self.chosenImageView setUserInteractionEnabled:YES];
    
    [self.templateImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.chosenImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.watermarkImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    if (isPhoneFive()) {
        self.renderView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, 432)];
        self.chosenImageView.frame = CGRectMake(0, 0,320,432);
    }else{
        self.renderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 432)];
        self.chosenImageView.frame = CGRectMake(0,0,320,432);
    }
    
    [self.renderView setClipsToBounds:YES];

    self.webViewController = [[WebViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(!self.pictureSelected) {
        self.cameraChosen = TRUE;
        [self.scaleRotateTabBar.retakeButton setTitle:@"Retake" forState:UIControlStateNormal];
        [self initImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
        self.imagePickerController.cameraOverlayView.frame = CGRectMake(0, 0, 320, screenHeight());
        [self.imagePickerController.cameraOverlayView addSubview:self.tabBar];
        
        
        self.imagePickerController.showsCameraControls = NO;
        if(![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            UIButton* btn = (UIButton*)self.tabBar.cameraDeviceButton;
            [btn setHidden:TRUE];
        }
        
        if(![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
            UIButton* btn = (UIButton*)self.tabBar.torchModeButton;
            [btn setHidden:TRUE];
        }

        [self presentViewController:self.imagePickerController animated:NO completion:nil];
        if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }

        NSLog(@"webview attempts to load %@", self.selectedTemplate.cAdTarget);
        
        self.webViewController.webTitle = @"";
        [self.webViewController view];
        [self.webViewController loadPageWithUrl:[NSURL URLWithString:self.selectedTemplate.cAdTarget]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark advert button
- (void)advertButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [FNMAppDelegate appDelegate].myCollectionViewController.selectedPicture = self.finalImage;
        [FNMAppDelegate appDelegate].myCollectionViewController.shareScreenMode = YES;
        // The My Collection view controller will not be able to retrive the template specific sharing text
        // until the upload process has completed and the id has been returned
        if(self.selectedTemplate.cTwitter) {
            [FNMAppDelegate appDelegate].myCollectionViewController.selectedPictureTwitter = self.selectedTemplate.cTwitter;
        }
        if(self.selectedTemplate.cFacebook) {
            [FNMAppDelegate appDelegate].myCollectionViewController.selectedPictureFacebook = self.selectedTemplate.cFacebook;
        }
        if(self.selectedTemplate.cEmail) {
            [FNMAppDelegate appDelegate].myCollectionViewController.selectedPictureEmail = self.selectedTemplate.cEmail;
        }
        self.selectedTemplate = nil;
        
        NSDictionary *test = objc_getAssociatedObject(self.finalImage, (const void*)0x314);
        
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
}

- (void)adLinkClicked:(id)sender
{
    if (self.webViewController.loadSuccess) {
        [FNMAdvertisement recordClick:self.selectedTemplate.cId];
        [self presentViewController:self.webViewController animated:YES completion:nil];
    } else {
        [[[FNMAlertView alloc] initWithTitle:@"Ad Error" message:@"There was a problem loading this website, please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]show];
    }
}

#pragma mark FNMGalleryDetailTabBarDelegate

- (void)cameraSelected
{
    self.cameraChosen = TRUE;
    [self.scaleRotateTabBar.retakeButton setTitle:@"Retake" forState:UIControlStateNormal];
    [self.imagePickerController takePicture];
}

- (void)librarySelected
{
    self.cameraChosen = FALSE;
    [self.scaleRotateTabBar.retakeButton setTitle:@"Re-choose" forState:UIControlStateNormal];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cancelSelected
{
    self.imagePickerController = nil;
    self.pictureSelected = TRUE;
    [self dismissViewControllerAnimated:NO completion:nil];//dismis UIImagePickerController
    [self dismissViewControllerAnimated:NO completion:nil];//dismiss self
}

- (void)cameraDeviceSelected
{
    if(self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        if([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront]) {
            [self.tabBar.torchModeButton setHidden:NO];
            [self.tabBar.torchModeButton setSelectedItem:1];
            [self.imagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeAuto];
        } else {
            [self.tabBar.torchModeButton setHidden:YES];
        }
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[[FNMAlertView alloc]initWithTitle:@"Lower Resolution" message:@"Using the front facing camera will result in lower resolution pictures." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]show];
        });
        
    } else {
        if([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]){
            [self.tabBar.torchModeButton setHidden:NO];
            [self.tabBar.torchModeButton setSelectedItem:1];
            [self.imagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeAuto];
        } else {
            [self.tabBar.torchModeButton setHidden:YES];
        }
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    
}

- (void)flashModeSelected:(DDExpandableButton*)sender
{
    switch (sender.selectedItem) {
        case 0:
            [self.imagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
            break;
        case 1:
            [self.imagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeAuto];
            break;
        case 2:
            [self.imagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
            break;
        default:
            break;
    }
}

#pragma mark FNMGalleryScaleRotateTabBarDelegate

- (void)retakeSelected
{
    if (self.cameraChosen) {
        self.imagePickerController = nil;
        [self initImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
        
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.imagePickerController.cameraOverlayView addSubview:self.tabBar];
        self.imagePickerController.cameraOverlayView.frame = CGRectMake(0, -1, 320, screenHeight());
        self.imagePickerController.showsCameraControls = NO;
        UIButton* btn = (UIButton *)[self.tabBar viewWithTag:TAG_FLASH_MODE];
        NSString* thePath = [[NSBundle mainBundle] pathForResource:@"camera_flash_auto_button" ofType:@"png"];
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:thePath];
        [btn setImage:image forState:UIControlStateNormal];
    } else {
        self.imagePickerController = nil;
        [self initImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];

    }
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentViewController:self.imagePickerController animated:NO completion:nil];
        if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }

    });
}

- (void)useSelected
{
    self.imagePickerController = nil;
    [self mergeAndSaveFinalImage];

    [self.view addSubview:self.advertImageView];
    self.advertImageView.frame = CGRectMake(0,0,320,screenHeight());
    [FNMAdvertisement recordImpression:self.selectedTemplate.cId];
}

#pragma mark UIImagePickerControllerDelegate

- (void)resetChosenImageFrame
{
    [self.chosenImageView setTransform:CGAffineTransformIdentity];
    [self.chosenImageView.layer setAnchorPoint:CGPointMake(.5, .5)];
    
    self.chosenImageView.frame = CGRectMake(0, 0, 320, 432);
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info
{

    [self resetChosenImageFrame];
    
    if (self.renderView) {
        [self.renderView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.renderView removeFromSuperview];
    }


    UIImage* image;
    UIImage *origImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (origImage == nil) {
        DLog(@"grabbed orig image");
        origImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            image = [UIImage imageWithCGImage:origImage.CGImage scale:origImage.scale orientation:UIImageOrientationLeftMirrored];
        } else {
            image = origImage;
        }
    }else{
        image = origImage;
    }

    

    if (self.selectedTemplate) {
        image = [self applyFilter:(fnmFilterType)[self.selectedTemplate.cEffect intValue] toImage:image withOptions:nil];
    }
    
    DLog(@"image size %@", NSStringFromCGSize(image.size));
    
    if (image.size.height > 1000) {
        image = [UIImage image:image scaleToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
    }
    
    DLog(@"image size %@", NSStringFromCGSize(image.size));

    [self.templateImageView removeFromSuperview];
    [self.watermarkImageView removeFromSuperview];
    [self.tabBar removeFromSuperview];
    
    
    
    [self.renderView addSubview:self.chosenImageView];
    [self.renderView addSubview:self.templateImageView];
    [self.renderView addSubview:self.watermarkImageView];
   
    [self.view addSubview:self.renderView];
    [self.view addSubview:self.scaleRotateTabBar];
    
    self.scaleRotateTabBar.frame = CGRectMake(0, screenHeight()-54, 320, 54);
    self.templateImageView.frame = CGRectMake(0,0,320,432);
    self.watermarkImageView.frame = self.templateImageView.frame;
    
    self.pictureSelected = TRUE;
    

    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.chosenImageView setImage:image];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self buildTutorialOverlay];
        });
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
    
}

- (void)removeTutorialOverlay
{
    [self.hideTutButton removeFromSuperview];
    [self.tutImage removeFromSuperview];
    
    self.tutImage = nil;
    self.hideTutButton = nil;
}

- (void)buildTutorialOverlay
{
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.tutImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
        [self.tutImage setImage:[UIImage imageNamed:@"overlay_scale-rotate_directions_iPhone5"]];
    }else{
        self.tutImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
        [self.tutImage setImage:[UIImage imageNamed:@"overlay_scale-rotate_directions"]];
    }
    
    [self.view addSubview:self.tutImage];
    [self.tutImage setUserInteractionEnabled:YES];
    
    self.hideTutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hideTutButton  addTarget:self action:@selector(removeTutorialOverlay) forControlEvents:UIControlEventTouchUpInside];
    [self.hideTutButton  setFrame:self.view.bounds];
    [self.view addSubview:self.hideTutButton];

}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{

    dispatch_async( dispatch_get_main_queue(), ^(void){
        [picker dismissViewControllerAnimated:YES completion:nil];

    });

}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
    }
}

- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //this is a workaround for iOS7 bug in picking from library
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

#pragma mark mergeImages and saveFinalImage

- (UIImage*) getImageFromView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, 430), view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)mergeAndSaveFinalImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [FinalPicture scheduleLocalNotificationForImage];
        [self.watermarkImageView removeFromSuperview];
        self.finalImage = [self getImageFromView:self.renderView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.advertButton setAlpha:0];
            [self.advertImageView addSubview:self.advertButton];
            [self.templateImageView removeFromSuperview];
            [self.tabBar removeFromSuperview];
            [self.chosenImageView removeFromSuperview];
            [self.scaleRotateTabBar removeFromSuperview];
        });
        
        NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *appDir = [documentDirectories objectAtIndex: 0];
        
        NSData *dataImage = [NSData dataWithData:UIImageJPEGRepresentation(self.finalImage, 1.0)];
        NSMutableString* fileName = [[NSMutableString alloc] initWithCapacity:10];
        NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
        [fileName appendString:guid];
        [fileName appendString:@".jpg"];
        
        NSString* selectedPictureFilePath = [NSString stringWithFormat:@"%@/%@",appDir,fileName];
        [dataImage writeToFile:selectedPictureFilePath atomically:YES];
        
        //Read it back out after parsing and saving to ensure that it's identical to what will be read later.
        dataImage = [NSData dataWithContentsOfFile:selectedPictureFilePath];
        self.finalImage = [UIImage imageWithData:dataImage];

        NSManagedObjectContext *context = [[VICoreDataManager getInstance] startTransaction];
        NSString *bgForTemplate = (NSString*)[NSNull null];
        NSString *facebookMessage = (NSString*)[NSNull null];
        NSString *twitterMessage = (NSString*)[NSNull null];
        NSString *emailMessage = (NSString*)[NSNull null];
        NSString *clientName = (NSString*)[NSNull null];
        if (self.selectedTemplate != nil) {
            if (self.selectedTemplate.cBackground != nil) {
                bgForTemplate = self.selectedTemplate.cBackground;
            }
            
            if (self.selectedTemplate.cEmail.length > 2) {
                emailMessage = self.selectedTemplate.cEmail;
            }
            
            if (self.selectedTemplate.cFacebook.length > 2) {
                facebookMessage = self.selectedTemplate.cFacebook;
            }
            
            if (self.selectedTemplate.cTwitter.length > 2) {
                twitterMessage = self.selectedTemplate.cTwitter;
            }

            if (self.selectedTemplate.cClientName != nil) {
                clientName = self.selectedTemplate.cClientName;
            }
        }

        NSMutableDictionary*attachInfo = [NSMutableDictionary dictionary];
        [attachInfo setValue:selectedPictureFilePath forKey:@"uri"];
        [attachInfo setValue:bgForTemplate forKey:@"background"];
        objc_setAssociatedObject(self.finalImage, (const void*)0x314, attachInfo, OBJC_ASSOCIATION_RETAIN);
        //this is attached twice to speed up the advertisement exit button, on old phones the final picture upload and save to core data would take a while
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.advertButton setAlpha:1];
        });

        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                bgForTemplate, LOCAL_PARAM_BG,
                                selectedPictureFilePath, LOCAL_PARAM_URI,
                                @(kUploadError), PARAM_STATUS,
                                twitterMessage, TEMPLATE_TWITTER,
                                facebookMessage, TEMPLATE_FACEBOOK,
                                emailMessage, TEMPLATE_EMAIL,
                                clientName, TEMPLATE_CLIENT_NAME,
                                [NSDate date], TEMPLATE_TIMESTAMP,
                                nil];

        FinalPicture *finalPicture =  [FinalPicture addWithParams:params forManagedObjectContext:context];
        
        [FinalPicture uploadCreatedPicture:self.finalImage forObject:finalPicture];

        [attachInfo setValue:finalPicture.itemId forKey:PARAM_ID];
        objc_setAssociatedObject(self.finalImage, (const void*)0x314, attachInfo, OBJC_ASSOCIATION_RETAIN);
        [[FNMAppDelegate appDelegate].myCollectionViewController setCurrentDeletableID:[params objectForKey:PARAM_ID]];
        
        [[VICoreDataManager getInstance] endTransactionForContext:context];
    });
}

- (void)initImagePickerWithSource:(UIImagePickerControllerSourceType)source
{
    self.imagePickerController.delegate = nil;
    self.imagePickerController = nil;
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:source]){
        [self.imagePickerController setSourceType:source];
    }else{
        [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }

    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.advertButton) {
        return NO;
    }else{
        return YES;
    }
}
@end
