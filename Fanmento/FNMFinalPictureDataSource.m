//
//  FNMFinalPictureDataSource.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/9/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMFinalPictureDataSource.h"
#import "FinalPicture.h"
#import "FNMCustomGalleryCell.h"
#import "FNMAppDelegate.h"
#import <objc/runtime.h>
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"

#import "UIImage+Decompression.h"

@implementation FNMFinalPictureDataSource

dispatch_queue_t imageDownloadQueue;

+ (void)initialize
{
    imageDownloadQueue = dispatch_queue_create("line up the image download queue", DISPATCH_QUEUE_SERIAL);
}

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ident = @"FNMCustomGalleryCell";
    FNMCustomGalleryCell *cell = (FNMCustomGalleryCell *)[self.tableView dequeueReusableCellWithIdentifier:ident];
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:cell action:@selector(cellImageSelected:)];
    
    if (cell == nil) {
        DLog(@"recreate cell");
        cell = (FNMCustomGalleryCell *)[[FNMCustomGalleryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        
    } else {
        [self cancelCell:cell];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[cell viewWithTag:1] setAlpha:0];
            [[cell viewWithTag:2] setAlpha:0];
            [[cell viewWithTag:-1] setAlpha:0];
            [[cell viewWithTag:-2] setAlpha:0];
        });
    }
    
    cell.delegate = (id <FNMCustomGalleryCellDelegate>) [[FNMAppDelegate appDelegate] myCollectionViewController];
    
    NSIndexPath *convertedIndex = [NSIndexPath indexPathForRow:indexPath.row*2 inSection:indexPath.section];
    if ([[self.fetchedResultsController fetchedObjects]count] > convertedIndex.row) {
        FinalPicture *finalPicture = [self.fetchedResultsController objectAtIndexPath:convertedIndex];
        
        UIImageView* btnLeft = (UIImageView *)[cell viewWithTag:1];
        [btnLeft addGestureRecognizer:tap];
        NSMutableString* cancelled =  [[NSMutableString alloc]initWithString:@"NO"];
        objc_setAssociatedObject(cell, (const void*)0x315, cancelled ,OBJC_ASSOCIATION_RETAIN);
        NSDictionary*params = [self makeDeleteInfoDictionary:finalPicture];
        dispatch_async(imageDownloadQueue, ^{
            [self setImage:params forItem:btnLeft andCancelled:cancelled];
        });
        
        UIImageView* btnRight = (UIImageView *)[cell viewWithTag:2];
        tap = [[UITapGestureRecognizer alloc]initWithTarget:cell action:@selector(cellImageSelected:)];
        [btnRight addGestureRecognizer:tap];
        
        
        convertedIndex = [NSIndexPath indexPathForRow:(indexPath.row*2)+1 inSection:indexPath.section];
        if ([[self.fetchedResultsController fetchedObjects]count] > convertedIndex.row) {
            FinalPicture *finalPictureTwo = [self.fetchedResultsController objectAtIndexPath:convertedIndex];
            NSDictionary*paramsTwo = [self makeDeleteInfoDictionary:finalPictureTwo];
            dispatch_async(imageDownloadQueue, ^{
                [self setImage:paramsTwo forItem:btnRight andCancelled:cancelled];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [btnRight setAlpha:0];
            });
        }
    }
    
    return cell;
}

- (void)setImage:(NSDictionary*)params forItem:(UIImageView*)imageView andCancelled:(NSString*)cancel
{
    [imageView setUserInteractionEnabled:YES];
    
    if (![[[NSURL URLWithString:[params objectForKey:@"uri"]]scheme]isEqualToString:@"http"]) {
        UIImage*passableImage = [[UIImage alloc]initWithContentsOfFile:[params objectForKey:@"uri"]];

        objc_setAssociatedObject(passableImage, (const void*)0x314, params,OBJC_ASSOCIATION_RETAIN);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([cancel isEqualToString:@"NO"]) {
                DLog(@"not canceled");
                [imageView setImage:passableImage];
                [imageView setAlpha:1];
            }else{
                DLog(@"canceled");
            }
            
        });
    }else{
        __block UIImageView* imageViewBlock = imageView;
        [imageView sd_setImageWithURL:[params objectForKey:@"uri"] placeholderImage:[UIImage imageNamed:@"bg_blank_for_pics.png"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.3 animations:^{
                    [imageViewBlock setAlpha:1];
                }];
            });
            if (image) {
                objc_setAssociatedObject(image, (const void*)0x314, params, OBJC_ASSOCIATION_RETAIN);
            }
        }];
    }
    
}

- (void)cancelCell:(UITableViewCell*)cell
{
    [(VILoaderImageView*)[cell viewWithTag:2] sd_cancelCurrentImageLoad];
    [(VILoaderImageView*)[cell viewWithTag:1] sd_cancelCurrentImageLoad];
    NSMutableString *cancel = objc_getAssociatedObject(cell, (const void*)0x315);
    [cancel setString:@""];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _rowCount = 0;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    if ([sectionInfo numberOfObjects]%2) {
        _rowCount = ([sectionInfo numberOfObjects]/2)+1;
    }else{
        _rowCount = [sectionInfo numberOfObjects]/2;
    }
    
    return _rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == (_rowCount-1)) {
        return 220;
    }else{
        return 206;        
    }
    
}

- (NSDictionary*)makeDeleteInfoDictionary:(FinalPicture*)object{
    
    NSDictionary*attachInfo = [NSMutableDictionary dictionary];
    [attachInfo setValue:object.uri forKey:@"uri"];
    [attachInfo setValue:object.itemId forKey:PARAM_ID];
    [attachInfo setValue:object.background forKey:@"background"];
    
    return attachInfo;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    DLog(@"Did change values");
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
        [self.tableView reloadData];
}

# pragma mark -
# pragma mark JPImagePickerControllerDataSource

- (NSInteger)numberOfImagesInImagePicker:(JPImagePickerController *)picker
{    
    int numberOfImages = 0;

    if ([[[FNMAppDelegate appDelegate]tabBarController]selectedIndex] == 4) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        numberOfImages = [sectionInfo numberOfObjects];
    }

    return numberOfImages;
}

- (UIImage *)imagePicker:(JPImagePickerController *)picker thumbnailForImageNumber:(NSInteger)imageNumber
{
    FinalPicture *obj = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:imageNumber inSection:0]];
    
    if (![[[NSURL URLWithString:obj.uri]scheme]isEqualToString:@"http"]) {
        return [UIImage image:[[UIImage alloc]initWithContentsOfFile:obj.uri] scaleAndCroppForSize:CGSizeMake(200, 200)];
    }else{
        return (UIImage*)obj.uri;
    }
}

- (UIImage *)imagePicker:(JPImagePickerController *)imagePicker imageForImageNumber:(NSInteger)imageNumber
{
    FinalPicture *obj = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:imageNumber inSection:0]];
    
    if (![[[NSURL URLWithString:obj.uri]scheme]isEqualToString:@"http"]) {
        return [[UIImage alloc]initWithContentsOfFile:obj.uri];
    }else{
        return (UIImage*)obj.uri;
    }
    
}

- (NSString *)clientNameForImageNumber:(NSInteger)imageNumber
{
    FinalPicture *obj = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:imageNumber inSection:0]];

    return obj.cClientName;
}

- (void)dealloc
{
    NSLog(@"memory management win %@", self.description);
}




@end
