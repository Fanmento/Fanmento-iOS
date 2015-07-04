//
//  FNMOrderPrintsViewController.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/29/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JPImagePickerController.h"
#import "WAG_CheckoutContext.h"
#import "WAG_ImageData.h"
#import "Fujifilm.WebViewController.h"
#import "FNMFinalPictureDataSource.h"

@interface FNMOrderPrintsViewController : UIViewController <JPImagePickerControllerDataSource,
                                                            JPImagePickerControllerDelegate,
                                                            CheckoutDelegate,
                                                            NSFetchedResultsControllerDelegate,
                                                            UIActionSheetDelegate>

@end
