//
//  FNMGalleryDetailViewController+Filters.h
//  Fanmento
//
//  Created by teejay on 11/12/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryDetailViewController.h"

typedef enum {
    fnmFilterNormal,
    fnmFilterLuma,
    fnmFilterEmboss,
    fnmFilterBlackWhite,
    fnmFilterSepia,
    fnmFilterToon,
    fnmFilterThreshold,
    fnmFilterAdaptive,
    fnmFilterPosterize,
    fnmFilterPolkaNil,
    fnmFilterPolkaMedium,
    fnmFilterPolkaLarge,
    fnmFilterCrosshatch,
    fnmFilterTrueBlue,
    fnmFilterNavyBlue,
    fnmFilterBullsRed,
    fnmFilterGold,
    fnmFilterYellow,
    fnmFilterHotOrange,
    fnmFilterTrueOrange,
    fnmFilterLimeGreen,
    fnmfilterDarkGreen,
    fnmFilterPurple
}fnmFilterType;
/*
True Blue - R;38 G;146 B;198
Navy Blue - R;0 G;33 B;87
Bulls Red - R: 158 B: 11 G: 15
Gold - R;192 G;147 B;21
Yellow - R;237 G;232 B;15
Hot Orange - R;226 G;78 B;48
True Orange - R;255 G;153 B;58
Lime Green - R;141 G;198 B;63
Dark Green - R;64 G;102 B;24
Purple - R;68 G;14 B;98
*/
#define fnmFilterOptionHexValue         @"filter.value.hexColor"
#define fnmAdaptiveFilterValue          11.259201

@interface FNMGalleryDetailViewController (Filters)

- (UIImage*)applyFilter:(fnmFilterType)filterType toImage:(UIImage*)inputImage withOptions:(NSDictionary*)options;

@end
