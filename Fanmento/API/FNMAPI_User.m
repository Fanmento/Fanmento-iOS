//
//  FNMAPI_User.m
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMAPI_User.h"
#import "APIConstants.h"
#import "VICoreDataManager.h"
#import "FNMUser.h"
#import "HttpUserCredentials.h"
#import "FinalPicture.h"
#import "FNMAppDelegate.h"

@implementation FNMAPI_User


+ (void)registerForEmail:(NSString *)email
                password:(NSString *)password
                    name:(NSString *)name
                   token:(NSString*)token
              completion:(void (^)(BOOL success, id object, NSInteger statusCode))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@%@%@", BASE_URL, API_VERSION,API_USERS];

        NSDictionary *params;

        if (password) {
            params = @{USER_EMAIL : email, USER_PASSWORD : password};
        } else {
            params = @{USER_EMAIL : email, USER_FB_TOKEN : token, USER_NAME : name};
        }

        NSError *error = nil;

        ResponseData *data = [[NetworkUtility getInstance]postForHttp:url withParameters:params authenticate:NO error:error];

        if(data.response.statusCode == 200){
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data.data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];
            HttpUserCredentials *user = [[HttpUserCredentials alloc] init];
            [user setPassword:(password!=nil?password:token)];
            [user setUsername:email];
            [HttpUserCredentials setCurrentUser:user];

            NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];

            [FNMUser addWithParams:results forManagedObjectContext:tempContext];
            [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil, data.response.statusCode);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, data.response.statusCode);
            });
        }
    });
}

+ (void)loginWithCompletion:(void (^)(BOOL success, id object, NSInteger statusCode))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@%@%@", BASE_URL, API_VERSION,API_USERS];

        NSError *error = nil;

        ResponseData *data = [[NetworkUtility getInstance] get:url withParameters:NULL authenticate:YES error:error];
        DLog(@"Login response: %d", data.response.statusCode);
        if(data.response.statusCode==200){
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data.data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];

            NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];

            [FNMUser addWithParams:results forManagedObjectContext:tempContext];
            [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil, data.response.statusCode);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, data.response.statusCode);
            });
        }
    });
}

+ (void)registerViaFacebook:(SCFacebookCallback)completion
{
    [FNMAppDelegate appDelegate].isFacebookLoginInProgress = YES;
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        [FNMAppDelegate appDelegate].isFacebookLoginInProgress = NO;
        if (success) {
            DLog(@"%@", getUserToken());
            [SCFacebook getUserFQL:USER_FQL callBack:^(BOOL success, id result) {
                if (success) {
                    DLog(@"%@", getUserToken());
                    if ([result isKindOfClass:[NSString class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(YES, nil);
                        });
                    } else {
                        [FNMAPI_User registerForEmail:result[@"email"]
                                             password:nil
                                                 name:result[@"name"]
                                                token:getUserToken()
                                           completion:^(BOOL success, id object, NSInteger statusCode) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(success, object);
                                               });
                                           }];
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(success, result);
                    });
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, result);
            });
        }
    }];
}

+ (void)syncUserCollectionPage:(NSInteger)page completion:(void (^)(BOOL success, BOOL morePages))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@?page=%i", BASE_URL, API_VERSION, API_USERS, API_COLLECTION, page];
        NSError *error = nil;

        ResponseData *data = [[NetworkUtility getInstance] get:url withParameters:NULL authenticate:YES error:error];

        if(data.response.statusCode == 200){
            NSDictionary *results =
                    [NSJSONSerialization JSONObjectWithData:data.data
                                                    options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers
                                                      error:&error];
            if (results[@"resources"]) {
                for (NSMutableDictionary *pic in results[@"resources"]) {
                    [pic setObject:@(kUploaded) forKey:PARAM_STATUS];
                }

                NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
                [FinalPicture addWithArray:results[@"resources"]  forManagedObjectContext:tempContext];
                [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

                BOOL morePages = [results[@"num_pages"] integerValue] > page;
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, morePages);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, NO);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, NO);
            });
        }
    });
}

@end
