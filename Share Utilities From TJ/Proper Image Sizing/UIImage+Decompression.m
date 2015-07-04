//
//  UIImage+Decompression.m
//  UIImage Decompression
//
//  Created by Sergio Tacconi on 6/22/09.
//  Copyright 2009 Sergio Tacconi. All rights reserved.
//
//  Provided by Sergio Tacconi on 11/23/09 at Murray Street Coffee Shop.

#import "UIImage+Decompression.h"


@implementation UIImage (SAT_Decompression) 


- (id)initWithContentsOfFileDecompressed:(NSString *)path
{
	UIImage *compressedImage = [[UIImage alloc] initWithContentsOfFile:path];
	
	if(!compressedImage)
	{
		return nil;
	}

	CGImageRef originalImage = [compressedImage CGImage];
	CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(originalImage));
	CGDataProviderRef imageDataProvider = CGDataProviderCreateWithCFData(imageData);
	CFRelease(imageData);
	
	CGImageRef image = CGImageCreate(CGImageGetWidth(originalImage),
									 CGImageGetHeight(originalImage),
									 CGImageGetBitsPerComponent(originalImage),
									 CGImageGetBitsPerPixel(originalImage),
									 CGImageGetBytesPerRow(originalImage),
									 CGImageGetColorSpace(originalImage),
									 CGImageGetBitmapInfo(originalImage),
									 imageDataProvider,
									 CGImageGetDecode(originalImage),
									 CGImageGetShouldInterpolate(originalImage),
									 CGImageGetRenderingIntent(originalImage));
	
	CGDataProviderRelease(imageDataProvider);
	
    self = [self initWithCGImage:image];
	
	CGImageRelease(image);
	
	return self;
}

@end
