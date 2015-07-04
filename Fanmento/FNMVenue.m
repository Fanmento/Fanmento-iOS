//
//  FNMVenue.m
//  Fanmento
//
//  Created by teejay on 1/9/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "FNMVenue.h"
#import "APIConstants.h"
#import "NSDate+API.h"

@implementation FNMVenue

@dynamic cName;
@dynamic cLatitude;
@dynamic cLongitude;
@dynamic cStartDate;
@dynamic cEndDate;
@dynamic cAddress;
@dynamic cId;


+ (NSArray*)addWithParams:(NSDictionary *)params forManagedObjectContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cId == %@", params[VENUE_ID]];

    FNMVenue *venue = [FNMVenue fetchForPredicate:predicate forManagedObjectContext:context];

    if (venue == nil) {
        DLog(@"venue returned nil");
        return [FNMVenue syncWithParams:params forManagedObjectContext:context];
    } else {
        return [FNMVenue editWithParams:params forObject:venue];
    }
}

+ (id)setInformationFromDictionary:(NSDictionary *)params forObject:(NSManagedObject *)object
{
    FNMVenue *venue = (FNMVenue*)object;

    venue.cId = [self attribute:venue.cId forParam:[params[VENUE_ID] stringValue]];

    venue.cName = [self attribute:venue.cName forParam:params[VENUE_NAME]];

    NSArray *locationComponents = [params[VENUE_LOCATION] componentsSeparatedByString:@","];
    if(locationComponents.count == 2) {
        venue.cLatitude = [self attribute:venue.cLatitude forParam:@([locationComponents[0] doubleValue])];
        venue.cLongitude = [self attribute:venue.cLongitude forParam:@([locationComponents[1] doubleValue])];
    }

    venue.cEndDate   = [self attribute:venue.cEndDate forParam:[NSDate dateFromApiString:params[VENUE_END]]];
    venue.cStartDate = [self attribute:venue.cStartDate forParam:[NSDate dateFromApiString:params[VENUE_START]]];

    return venue;
}

+ (NSArray*)getAllVenues
{
    return [[VICoreDataManager getInstance] arrayForModel:@"FNMVenue"];
}

+ (NSArray*)getCurrentVenues
{
    NSDate *now = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cStartDate <= %@) AND (cEndDate >= %@)", now, now];

    VICoreDataManager *cdm = [VICoreDataManager getInstance];
    NSManagedObjectContext *moc = [cdm managedObjectContext];

    NSArray *venues = [cdm arrayForModel:@"FNMVenue" withPredicate:predicate forContext:moc];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"cName" ascending:YES];
    venues = [venues sortedArrayUsingDescriptors:@[sorter]];
    return venues;
}
@end
