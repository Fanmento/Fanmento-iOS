//
//  FNMMyCollectionShareToolBar.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/3/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FNMMyCollectionShareToolBarDelegate <NSObject>
- (void)facebookSelected;
- (void)emailSelected;
- (void)twitterSelected;
- (void)shopSelected;
- (void)deleteSelected;
@end

@interface FNMMyCollectionShareToolBar : UIView

@property(assign) id<FNMMyCollectionShareToolBarDelegate> delegate;

- (void)disableDeleteButton;
- (void)enableDeleteButton;

@end
