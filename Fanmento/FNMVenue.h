//
//  FNMVenue.h
//  Fanmento
//
//  Created by teejay on 1/9/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VIManagedObject.h"

@interface FNMVenue : VIManagedObject

@property (nonatomic, retain) NSString * cName;
@property (nonatomic, retain) NSString * cAddress;
@property (nonatomic, retain) NSNumber * cLatitude;
@property (nonatomic, retain) NSNumber * cLongitude;
@property (nonatomic, retain) NSDate * cStartDate;
@property (nonatomic, retain) NSDate * cEndDate;
@property (nonatomic, retain) NSString * cId;


+ (NSArray*)getAllVenues;
+ (NSArray*)getCurrentVenues;

@end
