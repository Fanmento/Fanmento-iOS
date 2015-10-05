//
//  FanmentoTests.h
//  FanmentoTests
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIAutomation.h"

@interface FanmentoTests : XCTestCase
+ (BOOL) waitForCompletion:(NSTimeInterval)timeoutSecs;
+ (BOOL) doesActionViewExist;
+ (void) dismissAlertViews;
UIASyntheticEvents *events();
@end
