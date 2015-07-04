//
//  FNMAdvertisement.m
//  Fanmento
//
//  Created by Charles Bedrosian on 3/11/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "FNMAdvertisement.h"
#import "NetworkUtility.h"
#import "APIConstants.h"

@implementation FNMAdvertisement

+ (void)recordImpression:(NSNumber *)templateId
{
    if (!templateId) return;
    NSError *error = nil;
    NSString *url = [self getUrl:templateId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ResponseData *response = [[NetworkUtility getInstance] put:url withParameters:nil authenticate:YES error:error];
    #if DEBUG
        NSData *data = response.data;
        NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DLog(@"%@", url);
        DLog(@"Ad impression recorded: %@", responseString);
    #endif
    });
}

+ (void)recordClick:(NSNumber *)templateId
{
    if (!templateId) return;
    NSError *error = nil;
    NSString *url = [self getUrl:templateId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ResponseData *response = [[NetworkUtility getInstance] post:url withParameters:nil authenticate:YES error:error];
    #if DEBUG
        NSData *data = response.data;
        NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DLog(@"Ad click recorded: %@", responseString);
    #endif
    });
}

+ (NSString *)getUrl:(NSNumber *)templateId
{
    return [NSString stringWithFormat:@"%@%@%@%@/%@/", BASE_URL, API_VERSION, API_TEMPLATES, TEMPLATE_AD, templateId];
}

@end
