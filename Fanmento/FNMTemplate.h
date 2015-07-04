//
//  FNMTemplate.h
//  Fanmento
//
//  Created by teejay on 11/6/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import "VIManagedObject.h"

typedef enum {
    kTemplateSynced,
    kTemplatePendingSync,
} TemplateSyncStatus;

@interface FNMTemplate : VIManagedObject

@property (nonatomic, retain) NSString *cCategory;
@property (nonatomic, retain) NSString *cRemoteURL;
@property (nonatomic, retain) NSDate *cActiveDate;
@property (nonatomic, retain) NSDate *cExpiryDate;
@property (nonatomic, retain) NSString *cAdURL;
@property (nonatomic, retain) NSNumber *cIsPremium;
@property (nonatomic, retain) NSNumber *cIsPurchased;
@property (nonatomic, retain) NSNumber *cIsNearby;
@property (nonatomic, retain) NSNumber *cLatitude;
@property (nonatomic, retain) NSNumber *cLongitude;
@property (nonatomic, retain) NSNumber *cId;
@property (nonatomic, retain) NSString *cVenue;
@property (nonatomic, retain) NSString *cCode;
@property (nonatomic, retain) NSString *cDescription;
@property (nonatomic, retain) NSNumber *cEffect;
@property (nonatomic, retain) NSDecimalNumber *cPrice;
@property (nonatomic, retain) NSString *cName;
@property (nonatomic, retain) NSString *cBackground;
@property (nonatomic, retain) NSString *cProductIdentifier;
@property (nonatomic, retain) NSString *cAdTarget;
@property (nonatomic, retain) NSString *cClientName;

@property (nonatomic, retain) NSString *cEmail;
@property (nonatomic, retain) NSString *cFacebook;
@property (nonatomic, retain) NSString *cTwitter;
@property (nonatomic, retain) NSNumber *cStatus;

+ (NSArray *)addWithParams:(NSDictionary *)params forManagedObjectContext:(NSManagedObjectContext *)context;

+ (FNMTemplate *)getTemplateForImageURL:(NSString *)imageURL;
+ (void)setTemplateBought:(FNMTemplate *)object;

+ (NSArray *)getAllTemplatesWithoutVenue;
+ (NSArray *)getTemplatesForCategory:(NSString *)category;
+ (NSArray *)getTemplatesForLocation:(CLLocation *)location;
+ (NSArray *)getTemplatesForCode:(NSString *)code;

+ (void)ensureNoDuplicatePremiumTemplates:(NSManagedObjectContext *)context;
+ (void)setAllToPending:(NSManagedObjectContext *)context;
+ (void)setAllPendingToSynced:(NSManagedObjectContext *)context;
+ (void)deleteAllPending:(NSManagedObjectContext *)context;
+ (void)deleteAllTemplatesWithoutVenue;

@end
