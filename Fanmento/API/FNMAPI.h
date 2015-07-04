//
//  FNMAPI.h
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "APIConstants.h"
#import "NetworkUtility.h"

@interface FNMAPI : NSObject

+ (NSString *)checkForErrors:(NSDictionary *)response;

@end
