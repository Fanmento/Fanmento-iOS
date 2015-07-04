//
//  UIImage+Decompression.h
//  UIImage Decompression
//
//  Created by Sergio Tacconi on 6/22/09.
//  Copyright 2009 Sergio Tacconi. All rights reserved.
//
//  Provided by Sergio Tacconi on 11/23/09 at Murray Street Coffee Shop.

#import <Foundation/Foundation.h>


@interface UIImage (SAT_Decompression) 


- (id)initWithContentsOfFileDecompressed:(NSString *)path;

@end
