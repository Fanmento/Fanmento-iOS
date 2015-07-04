//
//  FNMCustomGalleryCell.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/30/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMCustomGalleryCell.h"
#import "VILoaderImageView.h"

@interface FNMCustomGalleryCell ()
- (IBAction)cellImageSelected:(id)sender;
@end

@implementation FNMCustomGalleryCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FNMCustomGalleryCell"
                                                     owner:self
                                                   options:nil];
        return [nib lastObject];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cellImageSelected:(UITapGestureRecognizer*)sender
{
    [self.delegate imageSelected:(UIButton*)sender];
}


@end
