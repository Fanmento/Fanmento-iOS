//
//  FNMAPI_Venue.h
//  Fanmento
//
//  Created by teejay on 1/9/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "FNMAPI.h"

@interface FNMAPI_Venue : FNMAPI

+ (void)syncAllLocationsCompletion:(void (^)(BOOL success, id object))completion;

@end
