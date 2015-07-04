//
//  FinalPicture.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/29/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FinalPicture.h"
#import "RemoteNetworkUtility.h"
#import "APIConstants.h"
#import "Constant.h"
#import "FNMAppDelegate.h"
#import "FNMMyCollectionViewController.h"
#import "NSDate+API.h"

#define fnmNotificationDelay 86400

@implementation FinalPicture

@dynamic itemId;
@dynamic uri;
@dynamic background;
@dynamic status;

@dynamic cFacebook;
@dynamic cEmail;
@dynamic cTwitter;
@dynamic cClientName;
@dynamic cTimestamp;

+ (FinalPicture*)addWithParams:(NSDictionary *)params forManagedObjectContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", params[PARAM_ID]];

    FinalPicture *finalPicture = (FinalPicture *)[self fetchForPredicate:predicate forManagedObjectContext:context];

    if (finalPicture != nil) {
        [self editWithParams:params forObject:finalPicture];
    } else {
        finalPicture = [self syncWithParams:params forManagedObjectContext:context];
    }

    return finalPicture;
}

+ (FinalPicture*)getPictureWithID:(NSNumber*)itemId
{
    NSManagedObjectContext *context = [[VICoreDataManager getInstance] startTransaction];
    DLog(@"Item ID: %@", itemId.stringValue);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];

    FinalPicture *finalPicture = [FinalPicture fetchForPredicate:predicate forManagedObjectContext:context];
    [[VICoreDataManager getInstance]endTransactionForContext:context];
    return finalPicture;
}

+ (id)setInformationFromDictionary:(NSDictionary *)params forObject:(NSManagedObject *)object
{
    if ([[params allKeys]containsObject:@"created"]) {
        return [self setInformationFromRemoteDictionary:params forObject:object];
    } else {
        return [self setInformationFromLocalDictionary:params forObject:object];
    }
}

+ (id)setInformationFromRemoteDictionary:(NSDictionary *)params forObject:(NSManagedObject *)object
{
    FinalPicture *finalPicture = (FinalPicture *)object;

    finalPicture.itemId = [params[PARAM_ID] isKindOfClass:[NSNull class]] && params[PARAM_ID] != nil ?
        finalPicture.itemId : params[PARAM_ID];

    finalPicture.uri = [params[REMOTE_PARAM_URI] isKindOfClass:[NSNull class]] && params[REMOTE_PARAM_URI] != nil ?
        finalPicture.uri : params[REMOTE_PARAM_URI];

    finalPicture.background = [params[REMOTE_PARAM_BG] isKindOfClass:[NSNull class]] && params[REMOTE_PARAM_BG] != nil ?
        finalPicture.background : params[REMOTE_PARAM_BG];

    finalPicture.status = [params[PARAM_STATUS] isKindOfClass:[NSNull class]] && params[PARAM_STATUS] != nil ?
        finalPicture.status : params[PARAM_STATUS];

    NSDate *timestampParsed = [NSDate dateFromApiString:params[PARAM_CREATED]];
    finalPicture.cTimestamp = [timestampParsed isKindOfClass:[NSNull class]] && timestampParsed != nil ?
        finalPicture.cTimestamp : timestampParsed;

    finalPicture.cFacebook = ([params[PARAM_FACEBOOK] isKindOfClass:[NSNull class]] || params[PARAM_FACEBOOK] == nil) ?
        finalPicture.cFacebook : params[PARAM_FACEBOOK];

    finalPicture.cTwitter = ([params[PARAM_TWITTER] isKindOfClass:[NSNull class]] || params[PARAM_TWITTER] == nil) ?
        finalPicture.cTwitter : params[PARAM_TWITTER];

    finalPicture.cEmail = ([params[PARAM_EMAIL] isKindOfClass:[NSNull class]] || params[PARAM_EMAIL] == nil) ?
        finalPicture.cEmail : params[PARAM_EMAIL];

    finalPicture.cClientName = ([params[TEMPLATE_CLIENT_NAME] isKindOfClass:[NSNull class]] || params[TEMPLATE_CLIENT_NAME] == nil) ?
        @"" : params[TEMPLATE_CLIENT_NAME];

    DLog(@"%@ %@", finalPicture.cTimestamp, finalPicture.uri);
    return finalPicture;
}

+ (id)setInformationFromLocalDictionary:(NSDictionary *)params forObject:(NSManagedObject *)object
{
    FinalPicture *finalPicture = (FinalPicture *)object;

    finalPicture.itemId = [params[PARAM_ID] isKindOfClass:[NSNull class]] && params[PARAM_ID] != nil ?
        finalPicture.itemId : [params objectForKey:PARAM_ID];

    finalPicture.uri = [params[LOCAL_PARAM_URI] isKindOfClass:[NSNull class]] && params[LOCAL_PARAM_URI] != nil ?
        finalPicture.uri : params[LOCAL_PARAM_URI];

    finalPicture.background = [params[LOCAL_PARAM_BG] isKindOfClass:[NSNull class]] && params[LOCAL_PARAM_BG] != nil ?
        finalPicture.background : params[LOCAL_PARAM_BG];

    finalPicture.status = [params[PARAM_STATUS] isKindOfClass:[NSNull class]] && params[PARAM_STATUS] != nil ?
        finalPicture.status : params[PARAM_STATUS];

    finalPicture.cFacebook = ([params[TEMPLATE_FACEBOOK] isKindOfClass:[NSNull class]] || params[TEMPLATE_FACEBOOK] == nil) ?
        finalPicture.cFacebook : params[TEMPLATE_FACEBOOK];

    finalPicture.cTwitter = ([params[TEMPLATE_TWITTER] isKindOfClass:[NSNull class]] || params[TEMPLATE_TWITTER] == nil) ?
        finalPicture.cTwitter : params[TEMPLATE_TWITTER];

    finalPicture.cEmail = ([params[TEMPLATE_EMAIL] isKindOfClass:[NSNull class]] || params[TEMPLATE_EMAIL] == nil) ?
        finalPicture.cEmail : params[TEMPLATE_EMAIL];

    finalPicture.cClientName = ([params[TEMPLATE_CLIENT_NAME] isKindOfClass:[NSNull class]] || params[TEMPLATE_CLIENT_NAME] == nil) ?
        @"" : params[TEMPLATE_CLIENT_NAME];

    finalPicture.cTimestamp = [NSDate date];

    return finalPicture;
}

+ (void)scheduleLocalNotificationForImage
{
    UILocalNotification *alert = [[UILocalNotification alloc]init];
    [alert setFireDate:[NSDate dateWithTimeIntervalSinceNow:fnmNotificationDelay]];
    [alert setAlertBody:@"You took a picture yesterday, don't forget you can print it out!"];
    [alert setAlertAction:@"View it"];

    [[UIApplication sharedApplication]scheduleLocalNotification:alert];
}

+ (void)setAllToPending:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(kUploaded)];
    NSArray *results = [[VICoreDataManager getInstance] arrayForModel:NSStringFromClass([self class])
                                                        withPredicate:predicate
                                                           forContext:context];
    
    if (results) {
        for (FinalPicture *pic in results) {
            [pic setStatus:@(kPendingSync)];
        }
    }
}

+ (void)setAllToPendingToUploaded:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(kPendingSync)];

    NSArray *results = [[VICoreDataManager getInstance] arrayForModel:NSStringFromClass([self class])
                                                        withPredicate:predicate
                                                           forContext:context];

    if (results) {
        for (FinalPicture *pic in results) {
            [pic setStatus:@(kUploaded)];
        }
    }
}

+ (void)deleteAllPending:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(kPendingSync)];
    
    NSArray *results = [[VICoreDataManager getInstance] arrayForModel:NSStringFromClass([self class])
                                                        withPredicate:predicate
                                                           forContext:context];

    if (results) {
        for (FinalPicture *pic in results) {
            [[VICoreDataManager getInstance] deleteObject:pic];
        }
    }
}

+ (void)setToUploaded:(FinalPicture*)editablePic withID:(NSNumber *)uniqueID
{    
    [editablePic setStatus:@(kUploaded)];
    [editablePic setItemId:uniqueID];
}

+ (void)setToError:(FinalPicture*)pic
{
    NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uri == %@", pic.uri];
    
    FinalPicture *editablePic = (FinalPicture *)[self fetchForPredicate:predicate forManagedObjectContext:tempContext];
    
    [editablePic setStatus:@(kUploadError)];
    
    [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
}

+ (void)retryAllErrored
{
    NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(kUploadError)];

    NSMutableArray *erroredPix;
    id results = [self fetchForPredicate:predicate forManagedObjectContext:tempContext];

    if ([results isKindOfClass:[NSArray class]]) {
        erroredPix = [results mutableCopy];
    } else if ([results isKindOfClass:[FinalPicture class]]) {
        erroredPix = [@[results] mutableCopy];
    } else {
        [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
        return;
    }

    for (FinalPicture *pic in erroredPix) {
        [self uploadCreatedPicture:[[UIImage alloc] initWithContentsOfFile:pic.uri] forObject:pic];
    }

    [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
}

+ (void)uploadCreatedPicture:(UIImage*)image forObject:(FinalPicture*)object
{
    NSError *error = nil;

    NSMutableDictionary *params = [@{} mutableCopy];

    if (((object.background != nil) && object.background.length > 2)) {
        params[REMOTE_PARAM_BG] = object.background;
    }

    if (((object.cTwitter != nil) && object.cTwitter.length>2)) {
        params[TEMPLATE_TWITTER] = object.cTwitter;
    }

    if (((object.cFacebook != nil) && object.cFacebook.length>2)) {
        params[TEMPLATE_FACEBOOK] = object.cFacebook;
    }

    if (((object.cEmail != nil) && object.cEmail.length>2)) {
        params[TEMPLATE_EMAIL] = object.cEmail;
    }

    if (object.cClientName != nil) {
        params[TEMPLATE_CLIENT_NAME] = object.cClientName;
    }

    if (object.cTimestamp != nil) {
        params[TEMPLATE_TIMESTAMP] = [NSNumber numberWithLong:[object.cTimestamp timeIntervalSince1970]];
    }

    ResponseData *response = [[NetworkUtility getInstance] post:[NSString stringWithFormat:@"%@%@%@%@", BASE_URL, API_VERSION, API_USERS, API_COLLECTION]
                                                 withParameters:params
                                                          image:image
                                                       withName:@"image"
                                                   authenticate:YES
                                                          error:error];

    NSData *data = response.data;

    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#if DEBUG
    DLog(@"RESPONSE: %@",responseString);
#endif

    if (!error && response.response.statusCode == 201) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:response.data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];

        [[[FNMAppDelegate appDelegate] myCollectionViewController] setCurrentDeletableID:[results objectForKey:PARAM_ID]];
        [FinalPicture setToUploaded:object withID:[results objectForKey:PARAM_ID]];
    }
}

+ (BOOL)deleteCreatedPicture:(FinalPicture*)object withKey:(NSNumber*)key
{
    NSError *error = nil;

    if (key == nil && object != nil) {
        key = object.itemId;
    }

    ResponseData *response = [[NetworkUtility getInstance] delete:[NSString stringWithFormat:@"%@%@%@%@%@", BASE_URL, API_VERSION, API_USERS, API_COLLECTION, key]
                                                   withParameters:nil
                                                     authenticate:YES
                                                            error:error];

    NSData *data = response.data;

    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#if DEBUG
    DLog(@"RESPONSE: %@",responseString);
#endif

    if (!error) {
        if (response.response.statusCode == 204 ||response.response.statusCode == 200){
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

@end
