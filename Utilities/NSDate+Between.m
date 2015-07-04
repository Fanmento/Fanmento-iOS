//
//  NSDate+Between.m
//  Fanmento
//
//  Created by teejay on 12/14/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "NSDate+Between.h"

@implementation NSDate (Between)

- (BOOL)isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([self compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([self compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}
@end
