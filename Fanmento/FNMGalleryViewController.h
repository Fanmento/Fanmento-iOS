//
//  FNMGalleryViewController.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "FNMCustomGalleryCell.h"
#import "ODRefreshControl.h"

typedef enum {
    fnmNullTag,
    fnmSportsTemplates,
    fnmEntertainmentTemplates,
    fnmMusicTemplates,
    fnmLifestyleTemplates,
    fnmMiscellaneousTemplates
} templateCategory;

@interface FNMGalleryViewController : UIViewController <UITableViewDelegate,
                                                        UITableViewDataSource,
                                                        FNMCustomGalleryCellDelegate,
                                                        UITextFieldDelegate,
                                                        UIPickerViewDataSource,
                                                        UIPickerViewDelegate,
                                                        CLLocationManagerDelegate>

@property(nonatomic, strong) ODRefreshControl *refresh;
@property(nonatomic, assign) BOOL displayLocationServicesAccessDeniedWarning;

- (void)captureLocationCode;

@end
