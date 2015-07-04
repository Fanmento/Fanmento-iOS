//
//  FNMFinalPictureRemover.m
//  Fanmento
//
//  Created by Bill Werges on 7/15/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "FNMFinalPictureRemover.h"
#import "Constant.h"
#import "FNMAPI_User.h"
#import "FinalPicture.h"
#import "VICoreDataManager.h"

@implementation FNMFinalPictureRemover

+ (void)removeServerDeletedPictures
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // If we haven't downloaded the users photos yet, there will be nothing to remove
        if(! [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_MY_COLLECTION_DOWNLOADED_KEY]) {
            return;
        }

        NSDate *now = [NSDate date];
        NSDate *lastCheckDate = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_MY_COLLECTION_REFRESH_KEY];
        // If we haven't stoared a last check date yet, make one up
        if(lastCheckDate == nil) {
            lastCheckDate = [NSDate distantPast];
        }
        NSDate *shouldRefreshDate = [lastCheckDate dateByAddingTimeInterval:MY_COLLECTION_REFRESH_DELAY];

        // If shouldRefreshDate is later than current time, do nothing
        if([now compare:shouldRefreshDate] == NSOrderedAscending) {
            return;
        }

        // Set all templates to pending
        NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
        [FinalPicture setAllToPending:tempContext];
        [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

        // Start downloading user collection
        NSInteger currentPage = 1;
        [self getNextPageOfUserCollection:currentPage];
    });
}

+ (void)getNextPageOfUserCollection:(NSInteger)page
{
    // syncUserCollection will change the pending status to uploaded
    [FNMAPI_User syncUserCollectionPage:page completion:^(BOOL success, BOOL morePages) {
        if(success) {
            if(morePages) {
                [self getNextPageOfUserCollection:(page + 1)];
            } else {
                // Successfully downloaded all pages, safe to delete any images that are still pending
                NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
                [FinalPicture deleteAllPending:tempContext];
                [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

                // Update the last refresh date for My Collection
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULTS_MY_COLLECTION_REFRESH_KEY];
            }
        } else {
            // We failed to download a page, so reset pending status on images
            NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
            [FinalPicture setAllToPendingToUploaded:tempContext];
            [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
        }
    }];
}

@end
