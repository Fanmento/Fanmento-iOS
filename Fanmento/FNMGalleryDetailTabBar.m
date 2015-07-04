//
//  FNMGalleryDetailTabBar.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/31/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryDetailTabBAr.h"
#import "VILoaderImageView.h"
#import "UIImageView+WebCache.h"

#define TAG_CANCEL 2
#define TAG_CAMERA 3
#define TAG_LIBRARY 4
#define TAG_IMAGE 5
#define TAG_CAMERA_DEVICE 10
#define TAG_FLASH_MODE 11

@interface FNMGalleryDetailTabBar ()
- (IBAction)buttonSelected:(id)sender;
@end

@implementation FNMGalleryDetailTabBar
@synthesize torchModeButton;

@synthesize legacyBar = _legacyBar;
@synthesize fiveBar = _fiveBar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FNMGalleryDetailTabBar"
                                                     owner:self
                                                options:nil];
        
        FNMGalleryDetailTabBar*bar = [nib lastObject];
        /*if (isPhoneFive()) {
            bar.fiveBar.hidden = NO;
            bar.legacyBar.hidden = YES;
        }else{
            bar.fiveBar.hidden = YES;
            bar.legacyBar.hidden = NO;
        }*/
        return bar;
    }
    return self;
}

-(void)setTemplateImage:(id)templateImage
{
    UIImageView* imageView = (UIImageView*)[self viewWithTag:TAG_IMAGE];
    if ([templateImage isKindOfClass:[UIImage class]]) {
        [imageView setImage:templateImage];
        [self.takePhotoButton setEnabled:YES];
    }else{
        [self.takePhotoButton setEnabled:NO];
        
        __block UIImageView*imageViewBlock = imageView;
        __block UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:act];
        [act setCenter:self.center];
        [act startAnimating];
        [imageView setAlpha:0];
        [(VILoaderImageView*)imageView setImageWithURL:[NSString stringWithFormat:@"%@=s863",templateImage] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [act stopAnimating];
                [act removeFromSuperview];
                [UIView animateWithDuration:.3 animations:^{
                    [imageViewBlock setAlpha:1];
                }];
            });
            [self.takePhotoButton setEnabled:YES];
        }];
    }
    
    if (isPhoneFive()) {
        [self maskAndTranslateForFive:imageView];
    }
}



- (void)maskAndTranslateForFive:(UIImageView*)imageView
{
    [imageView setFrame:CGRectMake(0, 44, 320, 432)];
    
    UIView*mask = [[UIView alloc]initWithFrame:CGRectMake(0, 475, 320, 45)];
    [mask setBackgroundColor:[UIColor blackColor]];
    [self insertSubview:mask atIndex:0];
    
    mask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [mask setBackgroundColor:[UIColor blackColor]];
    [self insertSubview:mask atIndex:0];
}

- (IBAction)buttonSelected:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case TAG_CANCEL:
            [self.delegate cancelSelected];
            break;
        case TAG_CAMERA:
            [self.delegate cameraSelected];
            break;
        case TAG_LIBRARY:
            [self.delegate librarySelected];
            break;
        case TAG_CAMERA_DEVICE:
            [self.delegate cameraDeviceSelected];
            break;
        case TAG_FLASH_MODE:
            [self.delegate flashModeSelected:sender];
            break;
        default:
            break;
    }
    
}

@end
