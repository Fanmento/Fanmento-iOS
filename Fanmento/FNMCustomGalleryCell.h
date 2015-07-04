//
//  FNMCustomGalleryCell.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/30/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FNMCustomGalleryCellDelegate <NSObject>

- (void)imageSelected:(UIButton *)theButton;

@end

@interface FNMCustomGalleryCell : UITableViewCell

@property(nonatomic, assign) id<FNMCustomGalleryCellDelegate> delegate;

@end
