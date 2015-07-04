//
//  FNMGalleryDetailTabBar.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/31/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDExpandableButton.h"

@protocol FNMGalleryDetailTabBarDelegate <NSObject>
- (void)cameraSelected;
- (void)librarySelected;
- (void)cancelSelected;
- (void)cameraDeviceSelected;
- (void)flashModeSelected:(id)sender;
@end

@interface FNMGalleryDetailTabBar : UIView

@property(assign) id<FNMGalleryDetailTabBarDelegate> delegate;
@property(nonatomic, retain) DDExpandableButton *torchModeButton;
@property(weak, nonatomic) IBOutlet UIButton* takePhotoButton;
@property(strong, nonatomic) IBOutlet UIButton* cameraDeviceButton;
@property(strong, nonatomic) IBOutlet UIView* fiveBar;
@property(strong, nonatomic) IBOutlet UIView* legacyBar;

- (void)setTemplateImage:(id)templateImage;

@end
