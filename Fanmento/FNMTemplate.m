//
//  FNMTemplate.m
//  Fanmento
//
//  Created by teejay on 11/6/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMTemplate.h"
#import "APIConstants.h"
#import "NSDate+API.h"

@implementation FNMTemplate

@dynamic cCategory;
@dynamic cRemoteURL;
@dynamic cVenue;
@dynamic cCode;
@dynamic cAdURL;
@dynamic cDescription;
@dynamic cEffect;
@dynamic cName;
@dynamic cActiveDate;
@dynamic cExpiryDate;
@dynamic cIsNearby;
@dynamic cLatitude;
@dynamic cLongitude;
@dynamic cId;
@dynamic cAdTarget;
@dynamic cBackground;
@dynamic cClientName;

@dynamic cPrice;
@dynamic cIsPremium; 
@dynamic cProductIdentifier;
@dynamic cIsPurchased;

@dynamic cFacebook;
@dynamic cEmail;
@dynamic cTwitter;
@dynamic cStatus;

#define TEMPLATE_MODEL @"FNMTemplate"
#define NEARBY_DISTANCE 1609.0f // Distance in meters for a template to be considered at a location

+ (NSArray *)addWithParams:(NSDictionary *)params forManagedObjectContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cId == %@", params[TEMPLATE_ID]];

    FNMTemplate *template = [FNMTemplate fetchForPredicate:predicate forManagedObjectContext:context];

    if (params[TEMPLATE_REMOTE_IMAGE] == nil) {
        return nil;
    }

    if (template == nil) {
        DLog(@"template returned nil");
        return [FNMTemplate syncWithParams:params forManagedObjectContext:context];
    } else {
        return [FNMTemplate editWithParams:params forObject:template];
    }
}

+ (NSArray *)getAllTemplates
{
    return [[VICoreDataManager getInstance] arrayForModel:TEMPLATE_MODEL];
}

+ (NSArray *)getAllTemplatesWithoutVenue
{
    NSArray *templates = [self getAllTemplates];
    NSMutableArray *venueTemplates = [@[] mutableCopy];

    for (int i = templates.count-1; i >= 0; i--) {
        FNMTemplate *template = templates[i];
        if (template.cVenue.length < 2) {
            [venueTemplates addObject:template];
        }
    }

    return [venueTemplates sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"cName" ascending:YES]]];
}

+ (NSArray *)getTemplatesForCategory:(NSString *)category
{
    NSArray *templates = [self getAllTemplates];
    NSMutableArray *catTemplates = [@[] mutableCopy];

    for (int i = templates.count-1; i >= 0; i--) {
        FNMTemplate *template = templates[i];
        if ([[template.cCategory lowercaseString] isEqualToString:[category lowercaseString]]
            && (template.cVenue == nil || template.cVenue.length < 2)) {
            [catTemplates addObject:template];
        }
    }

    return catTemplates;
}

+ (NSArray *)getTemplatesForLocation:(CLLocation *)location
{
    NSArray *allTemplates = [self getAllTemplates];
    NSMutableArray *nearbyTemplates = [[NSMutableArray alloc] init];

    for (FNMTemplate *template in allTemplates) {
        if(template.cLatitude.doubleValue && template.cLongitude.doubleValue) {
            CLLocation *templateLocation = [[CLLocation alloc] initWithLatitude:template.cLatitude.doubleValue
                                                                      longitude:template.cLongitude.doubleValue];
            if([templateLocation distanceFromLocation:location] <= NEARBY_DISTANCE) {
                [nearbyTemplates addObject:template];
            }
        }
    }

    return nearbyTemplates;
}

+ (NSArray *)getTemplatesForCode:(NSString *)code
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cCode LIKE[cd] %@", code];
    VICoreDataManager *cdm = [VICoreDataManager getInstance];
    NSArray *templates = [cdm arrayForModel:TEMPLATE_MODEL
                              withPredicate:predicate
                                 forContext:cdm.managedObjectContext];
    return templates;
}

+ (FNMTemplate *)getTemplateForImageURL:(NSString*)imageURL
{
    NSArray *templates = [FNMTemplate getAllTemplates];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cRemoteURL == %@", imageURL];
    NSArray *matchingTemplate = [templates filteredArrayUsingPredicate:predicate];

    FNMTemplate *template = [matchingTemplate lastObject];

    return  template;
}

+ (void)setTemplateBought:(FNMTemplate *)object
{
    NSManagedObjectContext *tempContext = [[VICoreDataManager getInstance] startTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cRemoteURL == %@", object.cRemoteURL];

    FNMTemplate *template = [FNMTemplate fetchForPredicate:predicate forManagedObjectContext:tempContext];
    template.cIsPurchased = @(YES);

    [[VICoreDataManager getInstance] endTransactionForContext:tempContext];
}

+ (id)setInformationFromDictionary:(NSDictionary *)params forObject:(NSManagedObject *)object
{
    FNMTemplate *template = (FNMTemplate *)object;

    template.cCategory = ([params[TEMPLATE_CATEGORY] isKindOfClass:[NSNull class]] || params[TEMPLATE_CATEGORY] == nil) ?
        template.cCategory : params[TEMPLATE_CATEGORY];

    if (params[TEMPLATE_BACKGROUND]) {
        template.cBackground = [params[TEMPLATE_BACKGROUND][TEMPLATE_REMOTE_IMAGE] isKindOfClass:[NSNull class]] ?
                                        template.cBackground : params[TEMPLATE_BACKGROUND][TEMPLATE_REMOTE_IMAGE];
    }

    if(params[TEMPLATE_ADVERTISEMENT]){
        template.cAdURL = [params[TEMPLATE_ADVERTISEMENT][TEMPLATE_REMOTE_IMAGE] isKindOfClass:[NSNull class]] ?
            template.cAdURL : params[TEMPLATE_ADVERTISEMENT][TEMPLATE_REMOTE_IMAGE];

        template.cAdTarget = [params[TEMPLATE_ADVERTISEMENT][TEMPLATE_AD_TARGET] isKindOfClass:[NSNull class]] ?
            template.cAdTarget : params[TEMPLATE_ADVERTISEMENT][TEMPLATE_AD_TARGET];
    }

    template.cId = ([params[TEMPLATE_ID] isKindOfClass:[NSNull class]] || params[TEMPLATE_ID] == nil) ?
        template.cId : @([params[TEMPLATE_ID] integerValue]);

    template.cRemoteURL = ([params[TEMPLATE_REMOTE_IMAGE] isKindOfClass:[NSNull class]] || params[TEMPLATE_REMOTE_IMAGE] == nil) ?
        template.cRemoteURL : params[TEMPLATE_REMOTE_IMAGE];

    if ([params[TEMPLATE_VENUE] isKindOfClass:[NSDictionary class]] && [params[TEMPLATE_VENUE] allKeys].count > 0) {
        template.cVenue = ([params[TEMPLATE_VENUE][TEMPLATE_NAME] isKindOfClass:[NSNull class]] || params[TEMPLATE_VENUE][TEMPLATE_NAME] == nil) ?
                            template.cVenue : params[TEMPLATE_VENUE][TEMPLATE_NAME];

        template.cExpiryDate = ([params[TEMPLATE_VENUE][VENUE_END] isKindOfClass:[NSNull class]] || params[TEMPLATE_VENUE][VENUE_END] == nil) ?
            template.cExpiryDate : [NSDate dateFromApiString:params[TEMPLATE_VENUE][VENUE_END]];

        if ([params[TEMPLATE_VENUE][VENUE_START] isKindOfClass:[NSNull class]] || params[TEMPLATE_VENUE][VENUE_START] == nil) {
            template.cActiveDate = nil;
        } else {
            template.cActiveDate = [NSDate dateFromApiString:params[TEMPLATE_VENUE][VENUE_START]];
        }

        if(params[TEMPLATE_VENUE][VENUE_LOCATION]) {
            NSArray *locationComponents = [params[TEMPLATE_VENUE][VENUE_LOCATION] componentsSeparatedByString:@","];
            if(locationComponents.count == 2) {
                template.cLatitude = @([locationComponents[0] doubleValue]);
                template.cLongitude = @([locationComponents[1] doubleValue]);
            }

        }
    } else {
        template.cVenue = nil;

        template.cExpiryDate = [NSDate distantFuture];
        template.cActiveDate = [NSDate distantPast];
    }

    template.cCode = ([params[TEMPLATE_CODE] isKindOfClass:[NSNull class]] || params[TEMPLATE_CODE] == nil) ?
        template.cCode : params[TEMPLATE_CODE];

    template.cDescription = ([params[TEMPLATE_DESCRIPTION] isKindOfClass:[NSNull class]] || params[TEMPLATE_DESCRIPTION] == nil) ?
        template.cDescription : params[TEMPLATE_DESCRIPTION];

    template.cEffect = ([params[TEMPLATE_EFFECT] isKindOfClass:[NSNull class]] || params[TEMPLATE_EFFECT] == nil) ?
        template.cEffect : params[TEMPLATE_EFFECT];

    template.cName = ([params[TEMPLATE_NAME] isKindOfClass:[NSNull class]] || params[TEMPLATE_NAME] == nil) ?
        template.cName : params[TEMPLATE_NAME];

    template.cIsNearby = ([params[TEMPLATE_NEARBY] isKindOfClass:[NSNull class]] || params[TEMPLATE_NEARBY] == nil) ?
        template.cIsNearby : params[TEMPLATE_NEARBY];

    if ([params[TEMPLATE_PRODUCT_ID] length] > 0) {
        template.cProductIdentifier = ([params[TEMPLATE_PRODUCT_ID] isKindOfClass:[NSNull class]] || params[TEMPLATE_PRODUCT_ID] == nil) ?
            template.cProductIdentifier : params[TEMPLATE_PRODUCT_ID];
        template.cIsPremium = @(YES);

        if ([template.cIsPurchased boolValue] == NO) {
            template.cIsPurchased = @(NO);
        }
    }

    template.cClientName = ([params[TEMPLATE_CLIENT_NAME] isKindOfClass:[NSNull class]] || params[TEMPLATE_CLIENT_NAME] == nil) ?
        template.cClientName : params[TEMPLATE_CLIENT_NAME];

    template.cFacebook = ([params[TEMPLATE_FACEBOOK] isKindOfClass:[NSNull class]] || params[TEMPLATE_FACEBOOK] == nil) ?
        template.cFacebook : params[TEMPLATE_FACEBOOK];

    template.cTwitter = ([params[TEMPLATE_TWITTER] isKindOfClass:[NSNull class]] || params[TEMPLATE_TWITTER] == nil) ?
        template.cTwitter : params[TEMPLATE_TWITTER];

    template.cEmail = ([params[TEMPLATE_EMAIL] isKindOfClass:[NSNull class]] || params[TEMPLATE_EMAIL] == nil) ?
        template.cEmail : params[TEMPLATE_EMAIL];

    template.cStatus = @(kTemplateSynced);

    return template;
}

+ (void)ensureNoDuplicatePremiumTemplates:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cIsPremium == 1"];
    NSArray *results = [[VICoreDataManager getInstance] arrayForModel:NSStringFromClass([self class])
                                                        withPredicate:predicate
                                                           forContext:context];

    for (FNMTemplate *template in results) {
        if (template.isDeleted) {
            //Do nothing, this is about to be deleted already.
            continue;
        }

        NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"cId == %@", template.cId];
        NSArray *templatesMatchingId = [results filteredArrayUsingPredicate:identifierPredicate];

        if (templatesMatchingId.count > 1) {
            for (int i = 1; i < templatesMatchingId.count; i++) {
                [context deleteObject:templatesMatchingId[i]];
            }
        }
    }
}

+ (void)setAllToPending:(NSManagedObjectContext *)context
{
    NSArray *results = [[VICoreDataManager getInstance] arrayForModel:NSStringFromClass([self class])
                                                        withPredicate:nil
                                                           forContext:context];

    if (results) {
        for (FNMTemplate *pic in results) {
            if (! [pic.cIsPurchased boolValue]) {
                [pic setCStatus:@(kTemplatePendingSync)];
            }
        }
    }
}

+ (void)setAllPendingToSynced:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cStatus == %@", @(kTemplatePendingSync)];

    NSArray *results = [[VICoreDataManager getInstance] arrayForModel:NSStringFromClass([self class])
                                                        withPredicate:predicate
                                                           forContext:context];

    if (results) {
        for (FNMTemplate *pic in results) {
            if (! [pic.cIsPurchased boolValue]) {
                [pic setCStatus:@(kTemplateSynced)];
            }
        }
    }
}

+ (void)deleteAllPending:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cStatus == %@", @(kTemplatePendingSync)];

    NSArray *results = [[VICoreDataManager getInstance] arrayForModel:NSStringFromClass([self class])
                                                        withPredicate:predicate
                                                           forContext:context];

    if (results) {
        for (FNMTemplate *pic in results) {
            [context deleteObject:pic];
        }
    }
}

+ (void)deleteAllTemplatesWithoutVenue
{
    VICoreDataManager *coreDataManager = [VICoreDataManager getInstance];

    NSArray *templates = [self getAllTemplates];

    for(int i = 0; i < templates.count; i++) {
        FNMTemplate *template = templates[i];
        if (template.cVenue.length < 2) {
            [coreDataManager deleteObject:template];
        }
    }

    [coreDataManager saveMainContext];
}

@end
