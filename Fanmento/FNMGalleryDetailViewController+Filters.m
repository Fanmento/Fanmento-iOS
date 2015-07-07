//
//  FNMGalleryDetailViewController+Filters.m
//  Fanmento
//
//  Created by teejay on 11/12/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryDetailViewController+Filters.h"
#import "GPUImage.h"

@implementation FNMGalleryDetailViewController (Filters)

- (UIImage*)applyFilter:(fnmFilterType)filterType toImage:(UIImage*)inputImage withOptions:(NSDictionary*)options
{
    GPUImageFilter*filter;
    
    switch (filterType) {
        case fnmFilterAdaptive:
        {
            
            filter = (GPUImageFilter*)[[GPUImageAdaptiveThresholdFilter alloc]init];
            [(GPUImageAdaptiveThresholdFilter*)filter setBlurRadiusInPixels:fnmAdaptiveFilterValue];
            
            break;
        }
        case fnmFilterBlackWhite:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){0.5f, 0.5f, 0.5f, 1.f}];
            break;
        }
        case fnmFilterCrosshatch:
        {
            filter = [(GPUImageFilter*)[GPUImageCrosshatchFilter alloc]init];
            [(GPUImageCrosshatchFilter*)filter setCrossHatchSpacing:.012];
            break;
        }
        case fnmFilterEmboss:
        {
            filter = (GPUImageFilter*)[[GPUImageEmbossFilter alloc]init];
            [(GPUImageEmbossFilter*)filter setIntensity:1.0];
            break;
        }
        case fnmFilterLuma:
        {
            filter = (GPUImageFilter*)[[GPUImageLuminanceThresholdFilter alloc]init];
            [(GPUImageLuminanceThresholdFilter*)filter setThreshold:.5];
            break;
        }
        case fnmFilterNormal:
        {
            return inputImage;
            break;
        }
        case fnmFilterPolkaLarge:
        {
            filter = (GPUImageFilter*)[[GPUImagePolkaDotFilter alloc]init];
            [(GPUImagePolkaDotFilter*)filter setFractionalWidthOfAPixel:.012776];
            break;
        }
        case fnmFilterPolkaMedium:
        {
            filter = (GPUImageFilter*)[[GPUImagePolkaDotFilter alloc]init];
            [(GPUImagePolkaDotFilter*)filter setFractionalWidthOfAPixel:.010568];
            break;
        }
        case fnmFilterPolkaNil:
        {
            filter = (GPUImageFilter*)[[GPUImagePolkaDotFilter alloc]init];
            [(GPUImagePolkaDotFilter*)filter setFractionalWidthOfAPixel:0.001];
            break;
        }
        case fnmFilterPosterize:
        {
            filter = (GPUImageFilter*)[[GPUImagePosterizeFilter alloc]init];
            [(GPUImagePosterizeFilter*)filter setColorLevels:round(3.367508)];
            break;
        }
        case fnmFilterSepia:
        {
            filter = (GPUImageFilter*)[[GPUImageSepiaFilter alloc]init];

            break;
        }
        case fnmFilterThreshold:
        {
            filter = (GPUImageFilter*)[[GPUImageLuminanceThresholdFilter alloc]init];
            [(GPUImageLuminanceThresholdFilter*)filter setThreshold:.414827];
            break;
        }
        case fnmFilterToon:
        {
            filter = (GPUImageFilter*)[[GPUImageSmoothToonFilter alloc]init];
            [(GPUImageSmoothToonFilter*)filter setBlurRadiusInPixels:.5];
            break;
        }
            
        case fnmFilterTrueBlue:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){38.0f/255.0f, 146.0f/255.0f, 198.0f/255.0f, 1.f}];
            break;
        }
            
        case fnmFilterNavyBlue:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){0.0f/255.0f, 33.0f/255.0f, 87.0f/255.0f, 1.f}];
            break;
        }
        case fnmFilterBullsRed:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){158.0f/255.0f, 11.0f/255.0f, 15.0f/255.0f, 1.f}];
            break;
        }
        case fnmFilterGold:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){192.0f/255.0f, 147.0f/255.0f, 21.0f/255.0f, 1.f}];
            break;
        }
        case fnmFilterYellow:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){237.0f/255.0f, 232.0f/255.0f, 15.0f/255.0f, 1.f}];
            break;
        }
            
        case fnmFilterHotOrange:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){226.0f/255.0f, 78.0f/255.0f, 48.0f/255.0f, 1.f}];
            break;
        }
            
        case fnmFilterTrueOrange:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){255.0f/255.0f, 153.0f/255.0f, 58.0f/255.0f, 1.f}];
            break;
        }
        case fnmFilterLimeGreen:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){141.0f/255.0f, 198.0f/255.0f, 63.0f/255.0f, 1.f}];
            break;
        }
            
        case fnmfilterDarkGreen:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){64.0f/255.0f, 102.0f/255.0f, 24.0f/255.0f, 1.f}];
            break;
        }
            
        case fnmFilterPurple:
        {
            filter = (GPUImageFilter*)[[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)filter setColor:(GPUVector4){68.0f/255.0f, 14.0f/255.0f, 98.0f/255.0f, 1.f}];
            break;
        }
    
        default:
            break;
    }
    
    
    UIImage *filteredImage = [filter imageByFilteringImage:inputImage];
    
    return filteredImage;
}

@end
