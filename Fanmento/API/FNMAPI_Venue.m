//
//  FNMAPI_Venue.m
//  Fanmento
//
//  Created by teejay on 1/9/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "FNMAPI_Venue.h"
#import "FNMVenue.h"
#import "FNMAppDelegate.h"
#import "NSDate+Between.h"
#import "APIConstants.h"

@implementation FNMAPI_Venue

+ (void)syncAllLocationsCompletion:(void (^)(BOOL success, id object))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@", BASE_URL, API_VERSION, API_TEMPLATES, API_VENUE];
        
        NSError *error = nil;
        
        ResponseData *data = [[NetworkUtility getInstance] get:url withParameters:NULL authenticate:YES error:error];
        
        if(data.response.statusCode==200){
            NSArray *results = [NSJSONSerialization JSONObjectWithData:data.data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];
            
            DLog(@"%@", [results description]);
            if (results && results.count > 0) {
                NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
                
                [FNMVenue addWithArray:results forManagedObjectContext:tempContext];
                [[VICoreDataManager getInstance] endTransactionForContext:tempContext];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [FNMAPI_Venue cleanExpiredTemplates];
                    if (completion) {
                        completion(YES, nil);
                    }
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[[FNMAlertView alloc]initWithTitle:@"Network Error" message:@"There was an error attempting to retreive venues, this may be due to low network signal. (Status Code Error)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]show];
                    if (completion) {
                        completion(NO, nil);
                    }
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[[FNMAlertView alloc]initWithTitle:@"Network Error" message:@"There was an error attempting to retreive venues, this may be due to low network signal. (Status Code Error)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]show];

                if (completion) {
                    completion(NO, nil);
                }
            });
        }
    });
}

+ (void)cleanExpiredTemplates
{
    //this is not threadsafe, must be called on the main queue
    NSArray*venues = [FNMVenue getAllVenues];
    for (FNMVenue *venue in venues) {
        if (![[NSDate date] isBetweenDate:venue.cStartDate andDate:venue.cEndDate]) {
            [[VICoreDataManager getInstance] deleteObject:venue];
        }
    }
    
    DLog(@"%@", ((NSArray*)[FNMVenue getAllVenues]).description);
}

@end
