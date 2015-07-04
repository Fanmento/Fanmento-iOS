//
//  FNMMyCollectionShareToolBar.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/3/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMMyCollectionShareToolBar.h"

#define TAG_FACEBOOK 5
#define TAG_EMAIL 2
#define TAG_TWITTER 3
#define TAG_SHOP 4

#define TAG_DELETE 6

@interface FNMMyCollectionShareToolBar ()

- (IBAction)buttonSelected:(id)sender;

@end


@implementation FNMMyCollectionShareToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FNMMyCollectionShareToolBar"
                                                     owner:self
                                                   options:nil];
        return [nib lastObject];
    }
    return self;
}

- (IBAction)buttonSelected:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case TAG_FACEBOOK:
            [self.delegate facebookSelected];
            break;
        case TAG_EMAIL:
            [self.delegate emailSelected];
            break;
        case TAG_TWITTER:
            [self.delegate twitterSelected];
            break;
        case TAG_SHOP:
            [self.delegate shopSelected];
            break;
        case TAG_DELETE:
            [self.delegate deleteSelected];
        default:
            break;
    }
    
}

- (void)disableDeleteButton
{
    ((UIButton *)[self viewWithTag:TAG_DELETE]).enabled = NO;

}

- (void)enableDeleteButton
{
    ((UIButton *)[self viewWithTag:TAG_DELETE]).enabled = YES;
}


@end
