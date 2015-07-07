//
//  FNMWalgreensAPITest.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 10/14/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WalgreensQPSDK/WalgreensQPSDK.h"

@protocol FNMWalgreensAPITestDelegate
- (void)failedAuthentication;
- (void)failedImageUpload;
- (void)failedPostCart;
@end

@interface FNMWalgreensAPITest : NSObject <WAGCheckoutDelegate>
{
    id delegate;
}

@property(strong, nonatomic) id <FNMWalgreensAPITestDelegate> delegate;

-(void)walgreensLogin:(NSString*)apiKey;
-(void)walgreensImageUpload;
-(void)walgreensPostCart;

@end
