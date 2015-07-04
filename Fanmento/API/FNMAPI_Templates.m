//
//  FNMAPI_Templates.m
//  Fanmento
//
//  Created by teejay on 11/6/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMAPI_Templates.h"
#import "APIConstants.h"
#import "FNMTemplate.h"
#import "VICoreDataManager.h"
#import "FNMAppDelegate.h"
#import "NSDate+Between.h"

@implementation FNMAPI_Templates

+ (void)syncTemplatesWithoutVenuePage:(NSInteger)page withCompletion:(void (^)(BOOL success, BOOL morePages))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static NSManagedObjectContext *tempContext;
        if(! tempContext) {
            tempContext = [[VICoreDataManager getInstance] startTransaction];
        }

        // If we are on the first page, set all templates to pending
        if(page == 1) {
            [FNMTemplate setAllToPending:tempContext];
        }

        NSString *url = [NSString stringWithFormat:@"%@%@%@%@?page=%d", BASE_URL, API_VERSION, API_TEMPLATES, API_GET_TEMPLATE, page];
        NSError *error = nil;

        ResponseData *data = [[NetworkUtility getInstance] get:url withParameters:NULL authenticate:YES error:error];

        if(data.response.statusCode == 200 && data.data != nil){
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data.data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];
            DLog(@"%@", [results description]);

            if ((results[@"resources"] != nil) && ([results[@"resources"] count] != 0)) {
                [FNMTemplate addWithArray:results[@"resources"] forManagedObjectContext:tempContext];
                [FNMAPI_Templates cleanExpiredTemplates:tempContext];

                BOOL morePages = [results[@"num_pages"] integerValue] > page;

                // Sync is complete, delete all pending templates
                if(! morePages) {
                    [FNMTemplate deleteAllPending:tempContext];
                    [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
                    tempContext = nil;
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(YES, morePages);
                    }
                });
            } else {
                // Sync failed, reset pending status
                [FNMTemplate setAllPendingToSynced:tempContext];
                [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
                tempContext = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(NO, NO);
                    }
                });
            }
        } else {
            // Sync failed, reset pending status
            [FNMTemplate setAllPendingToSynced:tempContext];
            [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
            tempContext = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO, NO);
                }
            });
        }
    });
}

+ (void)syncTemplatesForLocation:(CLLocation *)location
                            page:(NSInteger)page
                  withCompletion:(void (^)(BOOL success, BOOL morePages))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@?latitude=%f&longitude=%f&page=%d",
                         BASE_URL, API_VERSION, API_TEMPLATES, API_GET_TEMPLATE, location.coordinate.latitude, location.coordinate.longitude, page];
        NSError *error = nil;

        ResponseData *data = [[NetworkUtility getInstance] get:url withParameters:NULL authenticate:YES error:error];

        if(data.response.statusCode == 200 && data.data != nil){
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data.data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];
            DLog(@"%@", [results description]);

            if ((results[@"resources"] != nil) && ([results[@"resources"] count] != 0)) {
                NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
                [FNMTemplate addWithArray:results[@"resources"] forManagedObjectContext:tempContext];
                [FNMAPI_Templates cleanExpiredTemplates:tempContext];
                [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

                BOOL morePages = [results[@"num_pages"] integerValue] > page;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(YES, morePages);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(NO, NO);
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO, NO);
                }
            });
        }
    });
}

+ (void)syncTemplatesForCode:(NSString*)code withCompletion:(void (^)(BOOL success))completion
{
    if(! code) {
        if(completion) {
            completion(NO);
        }
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@",
                         BASE_URL, API_VERSION, API_TEMPLATES, API_GET_TEMPLATE, [code lowercaseString]];
        NSError *error = nil;
        NSDictionary*params = nil;

        ResponseData *data = [[NetworkUtility getInstance] get:url withParameters:params authenticate:YES error:error];
        if(data.response.statusCode==200){
            NSArray *results = [NSJSONSerialization JSONObjectWithData:data.data
                                                               options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers
                                                                 error:&error];

            NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
            [FNMTemplate addWithArray:results forManagedObjectContext:tempContext];
            [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(YES);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO);
                }
            });
        }
    });
}

+ (void)cleanExpiredTemplates:(NSManagedObjectContext*)context
{
    NSArray *templates = [[VICoreDataManager getInstance] arrayForModel:@"FNMTemplate"
                                                          withPredicate:nil
                                                             forContext:context];
    NSDate *currentDate = [NSDate date];
    for (FNMTemplate *template in templates) {
        if (![currentDate isBetweenDate:template.cActiveDate andDate:template.cExpiryDate]) {
            [context deleteObject:template];
        }
    }
}

@end
