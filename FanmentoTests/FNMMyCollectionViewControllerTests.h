//
//  FNMMyCollectionViewControllerTests.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 10/8/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FanmentoTests.h"
#import "FNMAppDelegate.h"
#import "FNMMyCollectionViewController.h"
#import "FNMWalgreensAPITest.h"

@interface FNMMyCollectionViewControllerTests : XCTestCase <FNMWalgreensAPITestDelegate>
{
    FNMAppDelegate *appDelegate;
    //FNMMyCollectionViewController *myCollectionViewController;
    FNMWalgreensAPITest* walgreensApiTest;
}

@end
