//
//  FNMWalgreensAPITest.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 10/14/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMWalgreensAPITest.h"
#import "Constant.h"

@interface FNMWalgreensAPITest ()

@property(strong, nonatomic) WalgreensQPSDK *checkouSDK;
@end

@implementation FNMWalgreensAPITest

@synthesize checkouSDK;
@synthesize delegate;

-(void)walgreeDLogin:(NSString*)apiKey
{
    checkouSDK = [[WalgreensQPSDK alloc] initWithAffliateId:WALGREENS_CHECKOUT_ACCESS_KEY apiKey:apiKey
                                                     environment:WALGREENS_ENVIRONMENT appVersion:WALGREENS_APP_VERSION
                                                  ProductGroupID:WALGREENS_PRODUCT_GROUP_ID PublisherID:WALGREENS_PUBLISHER_ID];
    checkouSDK.delegate = self;
}

-(void)walgreensImageUpload
{
    NSData* data = nil;
    [checkouSDK upload:data];
}

-(void)walgreensPostCart
{
    NSData* data = nil;
    [checkouSDK upload:data];//upload nil data for images then request a cart...should fail?
    [checkouSDK postCart];
}


#pragma mark CheckoutDelegate
// INIT
/**
 * ... This will be called when the authentication is success ...
 */
-(void) initSuccessResponse:(NSString*)response
{
    DLog(@"WAG TEST: Succesful Authentication: %@", response);
}

/**
 * ... This will be called when the authentication is failure ...
 */

-(void) didInitFailWithError:(NSError *)error
{
    DLog(@"WAG TEST: Failed Authentication: %@", error.localizedDescription);
    [delegate failedAuthentication];
}


#pragma mark Walgreens Checkout Error
//The SDK says that this method is optional, but they must not be doing proper checking, because the SDK crashed the app trying to call this method a few times
//Putting it in as a catch, instead of trying to fix Walgreens SDK.
-(void) initErrorResponse:(NSString*)response
{
    DLog(@"%@", response);
}

//IMAGE UPLOAD
/**
 * ... This will be called when the image upload process is success ...
 */


// New delegate methods support both single and multiple image upload
-(void) imageuploadSuccessWithImageData:(WAGImageData *)imageData
{
    DLog(@"WAG TEST: Succesful Image Upload");
    //[checkouSDK postCart];
}

-(void) imageuploadErrorWithImageData:(WAGImageData *)imageData  Error:(NSError *)error
{
    DLog(@"WAG TEST: Failed Image Upload");
    [delegate failedImageUpload];
}

/**
 * ... This will give the upload progress status ...
 */
-(void) getUploadProgress:(float)progress
{
    DLog(@"WAG TEST: Upload Progress: %f", progress);
}

//CART POSTER
/**
 * ... This will be called when the cartPoster returns url ...
 */
-(void) cartPosterSuccessResponse:(NSString*)response
{
    DLog(@"WAG TEST: Succesful Cart Poster: %@", response);
    //open webview here
}

/**
 * ... This will be called when the cartPoster process is failure ...
 */
-(void) didCartPostFailWithError:(NSError *)error
{
    DLog(@"WAG TEST: Cart Post Failed With Error: %@", error.localizedDescription);
    [delegate failedPostCart];
}


-(void) cartPosterErrorResponse:(NSString*)response
{
    DLog(@"WAG TEST: Error Cart Poster: %@", response);
    [delegate failedPostCart];
}

-(void) didFinishBatch
{
    DLog(@"WAG TEST: Did Finish Batch");
}

// EXCEPTION
/**
 * ... This will be called when there is any generic exception ...
 */

-(void) didServiceFailWithError:(NSError*)error
{
    DLog(@"WAG TEST: Service Fail With Error: %@", error.localizedDescription);
}

@end
