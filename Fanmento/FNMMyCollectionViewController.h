//
//  FNMMyCollectionViewController.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNMMyCollectionShareToolBar.h"
#import "FNMFinalPictureDataSource.h"
#import "FNMCustomGalleryCell.h"
#import "WalgreensQPSDK/WalgreensQPSDK.h"
#import <MessageUI/MessageUI.h>
#import "VILoaderImageView.h"
#import "MBProgressHUD.h"
#import "ODRefreshControl.h"
#import "Fujifilm.WebViewController.h"

@interface FNMMyCollectionViewController : UIViewController <FNMMyCollectionShareToolBarDelegate,
                                                             FNMCustomGalleryCellDelegate,
                                                             WAGCheckoutDelegate,
                                                             MFMailComposeViewControllerDelegate,
                                                             NSFetchedResultsControllerDelegate,
                                                             UIActionSheetDelegate>


@property (nonatomic) BOOL shareScreenMode;
@property (strong, nonatomic) UIImage *selectedPicture;
@property (strong, nonatomic) NSString *selectedPictureTwitter;
@property (strong, nonatomic) NSString *selectedPictureFacebook;
@property (strong, nonatomic) NSString *selectedPictureEmail;

@property (strong, nonatomic) VILoaderImageView *detailViewBackground;

@property (strong, nonatomic) NSNumber *currentDeletableID;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (assign, nonatomic) BOOL isVisible;

- (void)showHud;
- (void)hideHud;

@end
