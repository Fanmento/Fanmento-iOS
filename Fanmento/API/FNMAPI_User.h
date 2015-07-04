//
//  FNMAPI_User.h
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNMAPI.h"
#import "SCFacebook.h"

@interface FNMAPI_User : FNMAPI

+ (void)registerForEmail:(NSString *)email
                password:(NSString *)password
                    name:(NSString *)name
                   token:(NSString*)token
              completion:(void (^)(BOOL success, id object, NSInteger statusCode))completion;

+ (void)loginWithCompletion:(void (^)(BOOL success, id object, NSInteger statusCode))completion;

+ (void)registerViaFacebook:(SCFacebookCallback)callBack;

+ (void)syncUserCollectionPage:(NSInteger)page completion:(void (^)(BOOL success, BOOL morePages))completion;

@end
