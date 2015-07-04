//
//  FNMGalleryDetailViewController.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/31/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNMGalleryDetailTabBar.h"
#import "FNMGalleryScaleRotateTabBar.h"
#import "FNMTemplate.h"

@class DDExpandableButton;

@interface FNMGalleryDetailViewController : UIViewController <FNMGalleryDetailTabBarDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,FNMGalleryScaleRotateDelegate, DDExpandableButtonViewSource, UIGestureRecognizerDelegate>

@property(strong, nonatomic) id templateImage;

@property(strong, nonatomic) FNMTemplate *selectedTemplate;

- (id)initWithImage:(UIImage *)image;

@end
