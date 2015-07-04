//
//  FNMAPI.m
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMAPI.h"

@implementation FNMAPI

+ (NSString *)checkForErrors:(NSDictionary *)response
{
    if (response) {
        if ([response objectForKey:API_ERROR]) {
            return [[response objectForKey:API_ERROR]lastObject];
        }
    }
    return nil;
}

@end
