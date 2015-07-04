//
//  FNMFinalPictureDataSource.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/9/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "VIFetchResultsDataSource.h"
#import "JPImagePickerController.h"

@interface FNMFinalPictureDataSource : VIFetchResultsDataSource <JPImagePickerControllerDataSource, VIFetchResultsDataSourceDelegate>

@property(nonatomic, assign) NSInteger rowCount;

- (NSString *)clientNameForImageNumber:(NSInteger)imageNumber;

@end
