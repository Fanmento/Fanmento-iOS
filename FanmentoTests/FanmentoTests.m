//
//  FanmentoTests.m
//  FanmentoTests
//
//  Created by Dean Andreakis Mac Mini Account on 8/28/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FanmentoTests.h"
#import "VICoreDataManager.h"

@implementation FanmentoTests

- (void)setUp
{
    [super setUp];
    [[VICoreDataManager getInstance] resetCoreData];
}

- (void)tearDown
{
    [super tearDown];
}

//Grab a UIASyntheticEvents object, the rest of UIAutomation is flakey.
UIASyntheticEvents *events()
{
    return [NSClassFromString(@"UIASyntheticEvents") sharedEventGenerator];
}

+ (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (1);
    
    return YES;
}

+(BOOL) doesActionViewExist
{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0) {
            BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            if (action)
                return YES;
        }
    }
    return NO;
}

+(void) dismissAlertViews
{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]]){
                [[subviews objectAtIndex:0] dismissWithClickedButtonIndex:0 animated:NO];
            }
    }
}

@end
