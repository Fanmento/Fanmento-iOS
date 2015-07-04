//
//  FinalPicture.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 8/29/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VIManagedObject.h"

#define LOCAL_PARAM_URI    @"uri"
#define LOCAL_PARAM_BG     @"background"

#define REMOTE_PARAM_URI   @"url"
#define REMOTE_PARAM_BG    @"background_url"

#define PARAM_STATUS       @"status"
#define PARAM_TIMESTAMP    @"timestamp"
#define PARAM_ID           @"id"
#define PARAM_CREATED      @"created"
#define PARAM_TWITTER      @"twitter_message"
#define PARAM_FACEBOOK     @"facebook_message"
#define PARAM_EMAIL        @"email_message"

typedef enum {
    kUploadError,
    kUploaded,
    kPendingSync,
} UploadStatus;

@interface FinalPicture : VIManagedObject

@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * background;
@property (nonatomic, retain) NSString * cEmail;
@property (nonatomic, retain) NSString * cFacebook;
@property (nonatomic, retain) NSString * cTwitter;
@property (nonatomic, retain) NSString * cClientName;
@property (nonatomic, retain) NSDate   * cTimestamp;

+ (FinalPicture*)addWithParams:(NSDictionary *)params forManagedObjectContext:(NSManagedObjectContext *)context;
+ (FinalPicture*)getPictureWithID:(NSNumber*)itemId;
+ (void)scheduleLocalNotificationForImage;

+ (void)retryAllErrored;
+ (void)setToError:(FinalPicture*)pic;

+ (void)setToUploaded:(FinalPicture*)pic withID:(NSNumber*)uniqueID;
+ (void)setAllToPending:(NSManagedObjectContext*)context;
+ (void)setAllToPendingToUploaded:(NSManagedObjectContext *)context;
+ (void)deleteAllPending:(NSManagedObjectContext*)context;
+ (void)uploadCreatedPicture:(UIImage*)image forObject:(FinalPicture*)object;
+ (BOOL)deleteCreatedPicture:(FinalPicture*)object withKey:(NSNumber*)key;

@end
