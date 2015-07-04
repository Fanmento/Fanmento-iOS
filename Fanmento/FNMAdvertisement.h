//
//  FNMAdvertisement.h
//  Fanmento
//
//  Created by Charles Bedrosian on 3/11/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNMAdvertisement : NSObject

+ (void)recordImpression:(NSNumber *)templateId;
+ (void)recordClick:(NSNumber *)templateId;

@end
