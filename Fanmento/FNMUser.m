//
//  FNMUser.m
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMUser.h"
#import "APIConstants.h"


@implementation FNMUser

@dynamic cEmail;
@dynamic cFBToken;
@dynamic cUserId;

@dynamic cName;
@dynamic cPhone;


+ (void)addWithParams:(NSDictionary *)params forManagedObjectContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cUserId == %@", [params objectForKey:USER_ID]];
    
    FNMUser *user = [FNMUser fetchForPredicate:predicate forManagedObjectContext:context];
    
    if (user == nil) {
        [FNMUser syncWithParams:params forManagedObjectContext:context];
    } else {
        [FNMUser editWithParams:params forObject:user];
    }
}

+ (id)setInformationFromDictionary:(NSDictionary *)params forObject:(NSManagedObject *)object
{
    FNMUser *user = (FNMUser*)object;
    
    user.cUserId = [[params objectForKey:USER_ID] isKindOfClass:[NSNull class]] ? user.cUserId :
    [params objectForKey:USER_ID];

    user.cName = [[params objectForKey:USER_NAME] isKindOfClass:[NSNull class]] ? user.cName :
    [params objectForKey:USER_NAME];
    
    user.cPhone = [[params objectForKey:USER_PHONE] isKindOfClass:[NSNull class]] ? user.cPhone :
    [params objectForKey:USER_PHONE];
    
    user.cEmail = [[params objectForKey:USER_EMAIL] isKindOfClass:[NSNull class]] ? user.cEmail :
    [params objectForKey:USER_EMAIL];
    
    user.cFBToken = [[params objectForKey:USER_FB_TOKEN] isKindOfClass:[NSNull class]] ? user.cFBToken :
    [params objectForKey:USER_FB_TOKEN];
    
    
    return user;
}



@end
