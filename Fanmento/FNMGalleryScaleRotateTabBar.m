//
//  FNMGalleryScaleRotateTabBar.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/31/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryScaleRotateTabBar.h"

#define TAG_RETAKE 2
#define TAG_USE 4

@interface FNMGalleryScaleRotateTabBar ()

- (IBAction)buttonSelected:(id)sender;

@end


@implementation FNMGalleryScaleRotateTabBar

@synthesize retakeButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FNMGalleryScaleRotateTabBar"
                                                     owner:self
                                                   options:nil];
        return [nib lastObject];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)buttonSelected:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case TAG_RETAKE:
            [self.delegate retakeSelected];
            break;
        case TAG_USE:
            [self.delegate useSelected];
            break;
        default:
            break;
    }
    
}

@end
