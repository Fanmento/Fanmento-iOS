//
//  FNMGalleryScaleRotateTabBar.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/31/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FNMGalleryScaleRotateDelegate <NSObject>
- (void)retakeSelected;
- (void)useSelected;
@end

@interface FNMGalleryScaleRotateTabBar : UIView


@property(assign) id<FNMGalleryScaleRotateDelegate> delegate;
@property(strong, nonatomic) IBOutlet UIButton* retakeButton;

@end
