//
//  NSDate+API.m
//  Fanmento
//
//  Created by Charles Bedrosian on 2/27/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "NSDate+API.h"

@implementation NSDate (API)

+ (NSDate *)dateFromApiString:(NSString *)dateString
{
    
    static NSDateFormatter *df1;
    static NSDateFormatter *df2;
    static NSDateFormatter *df3;
    static NSDateFormatter *df4;
    if (!df1) {
        df1 = [[NSDateFormatter alloc]init];
        [df1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        df2 = [[NSDateFormatter alloc]init];
        [df2 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [df2 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        df3 = [[NSDateFormatter alloc] init];
        [df3 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
        df4 = [[NSDateFormatter alloc] init];
        [df4 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    }
    NSDate *r = [df1 dateFromString:dateString];
    if (!r) {
        r = [df2 dateFromString:dateString];
    }
    if (!r) {
        r = [df3 dateFromString:dateString];
    }
    if (!r) {
        r = [df4 dateFromString:dateString];
    }
    return r;
}


@end
