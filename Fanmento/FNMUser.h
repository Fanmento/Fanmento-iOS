//
//  FNMUser.h
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VIManagedObject.h"

@interface FNMUser : VIManagedObject

@property(nonatomic, retain) NSString * cEmail;
@property(nonatomic, retain) NSString * cFBToken;
@property(nonatomic, retain) NSNumber * cUserId;

@property(nonatomic, retain) NSString * cName;
@property(nonatomic, retain) NSString * cPhone;

+ (void)addWithParams:(NSDictionary *)params forManagedObjectContext:(NSManagedObjectContext *)context;

+ (id)setInformationFromDictionary:(NSDictionary *)params forObject:(NSManagedObject *)object;

@end
