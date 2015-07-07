//
//  FNMMyCollectionViewControllerTests.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 10/8/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMMyCollectionViewControllerTests.h"
#import <dlfcn.h>
#import "Constant.h"

@interface FNMMyCollectionViewControllerTests()
@property(nonatomic) BOOL failedAuth;
@property(nonatomic) BOOL failedImage;
@property(nonatomic) BOOL failedCart;
@end

@implementation FNMMyCollectionViewControllerTests

@synthesize failedAuth, failedImage, failedCart;

-(void)setUp
{
    appDelegate = [[UIApplication sharedApplication]delegate];
    dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);
    //myCollectionViewController = [appDelegate myCollectionViewController];
    walgreensApiTest = [[FNMWalgreensAPITest alloc] init];
    walgreensApiTest.delegate = self;
    failedAuth = FALSE;
    failedImage = FALSE;
    failedCart = FALSE;
}


//TS1.6 User Prints Photo to Walgreens (from fanmento test plan)
//uses Library button to choose picture
//precondition: 1 or more photos in photo library
-(void)test00PrintPhotoToWalgreens
{
    [events() sendTap:CGPointMake(100, 479)];//templates tab
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(100, 20)];//choose template in upper left of grid/table
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(50, 460)];//select the library button
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(160, 260)];//dismiss the alert
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(160, 60)];//select camera roll row
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(20, 60)];//select picture in upper left corner
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(300, 460)];//dismiss the help screen
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(300, 460)];//select the use button
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(281, 10)];//select the close (circle x) button
    [FanmentoTests waitForCompletion:5];
    
    //select share btn in lower right corner of image
    [events() sendTap:CGPointMake(260, 400)];
    [FanmentoTests waitForCompletion:5];
    
    //select shop/print btn
    [events() sendTap:CGPointMake(260, 345)];
    [FanmentoTests waitForCompletion:10];
    
    //select next btn at bottom of web view
    [FanmentoTests dismissAlertViews];
    [events() sendTap:CGPointMake(160, 440)];
    [FanmentoTests waitForCompletion:10];
    
    //select first row of store location table view
    [FanmentoTests dismissAlertViews];
    [events() sendTap:CGPointMake(160, 90)];
    [FanmentoTests waitForCompletion:10];
    
    //select cancel btn in upper right of web view (at this point can fill in form and submit also and should be taken back to my collection tab)
    //[FanmentoTests dismissAlertViews];
    void(^tryTap4)() = ^(void){
        [events() sendTap:CGPointMake(300, 20)];
    };
    [appDelegate executeBlock:tryTap4];
    [FanmentoTests waitForCompletion:3];
    
    //dismiss popup with "OK" btn....should be taken back to my collection tab
    void(^tryTap5)() = ^(void){
        [events() sendTap:CGPointMake(228, 275)];
    };
    [appDelegate executeBlock:tryTap5];
    [FanmentoTests waitForCompletion:5];
    
    NSAssert([appDelegate.tabBarController selectedIndex] == 0, @"Not on My Collections Tab");
}

//TS1.9 User Views App Version
-(void)test04AppVersion
{
    NSString *version = [NSString stringWithFormat:@"%@ Build %@",
                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    NSAssert([version length] != 0, @"Empty or nil version string");
}


//TS1.10 Walgreens API Failure: authentication
-(void)test01WalgreensAPIFailAuthentication
{
    [walgreensApiTest walgreensLogin:@"not the api key"];
    [FanmentoTests waitForCompletion:10];
    NSAssert(failedAuth == TRUE, @"walgreens authentication api test failed");
}

//TS1.11 Walgreens API Image Upload Failure
-(void)test02WalgreensAPIFailImageUpload
{
    [walgreensApiTest walgreensLogin:WALGREENS_CHECKOUT_API_KEY];//login sucessfully
    [FanmentoTests waitForCompletion:10];
    [walgreensApiTest walgreensImageUpload];
    [FanmentoTests waitForCompletion:10];
    NSAssert(failedImage == TRUE, @"walgreens image upload api test failed");
}

//TS1.12 Walgreens API Failure: posting cart
-(void)test03WalgreensAPIFailPostingCart
{
    [walgreensApiTest walgreensLogin:WALGREENS_CHECKOUT_API_KEY];//login sucessfully
    [FanmentoTests waitForCompletion:10];
    [walgreensApiTest walgreensPostCart];
    [FanmentoTests waitForCompletion:10];
    NSAssert(failedCart == TRUE, @"walgreens post cart api test failed");
}

-(void)tearDown
{
    
}

#pragma mark FNMWalgreensAPITestDelegate
-(void)failedAuthentication
{
    failedAuth = TRUE;
}

- (void)failedImageUpload
{
    failedImage = TRUE;
}

- (void)failedPostCart
{
    failedCart = TRUE;
}

@end
