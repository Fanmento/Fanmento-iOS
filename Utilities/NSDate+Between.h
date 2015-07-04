//
//  NSDate+Between.h
//  Fanmento
//
//  Created by teejay on 12/14/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Between)
- (BOOL)isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
@end
