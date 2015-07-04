//
//  FNMAPI_Templates.h
//  Fanmento
//
//  Created by teejay on 11/6/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMAPI.h"

#import <CoreLocation/CoreLocation.h>

@interface FNMAPI_Templates : FNMAPI

+ (void)syncTemplatesWithoutVenuePage:(NSInteger)page
                       withCompletion:(void (^)(BOOL success, BOOL morePages))completion;

+ (void)syncTemplatesForLocation:(CLLocation *)location
                            page:(NSInteger)page
                  withCompletion:(void (^)(BOOL success, BOOL morePages))completion;

+ (void)syncTemplatesForCode:(NSString*)code
              withCompletion:(void (^)(BOOL success))completion;

@end
