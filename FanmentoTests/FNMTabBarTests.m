//
//  FNMTabBarTests.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/13/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMTabBarTests.h"
#import <dlfcn.h>

@implementation FNMTabBarTests

-(void)setUp
{
    appDelegate = [[UIApplication sharedApplication]delegate];
    dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);
}

-(void)tearDown
{
    
}

-(void)test00TabBarTouches
{
    [FanmentoTests waitForCompletion:3];
    for (int x = 0; x < 200; x++) {
        void(^tryTap1)() = ^(void){
            [events() sendTap:CGPointMake(30, 479)];
        };
        [appDelegate executeBlock:tryTap1];
        [FanmentoTests waitForCompletion:.2];
        
        void(^tryTap2)() = ^(void){
            [events() sendTap:CGPointMake(100, 479)];
        };
        [appDelegate executeBlock:tryTap2];
        [FanmentoTests waitForCompletion:.2];
        
        void(^tryTap3)() = ^(void){
            [events() sendTap:CGPointMake(220, 479)];
        };
        [appDelegate executeBlock:tryTap3];
        [FanmentoTests waitForCompletion:.2];
        
        void(^tryTap4)() = ^(void){
            [events() sendTap:CGPointMake(300, 479)];
        };
        [appDelegate executeBlock:tryTap4];
        [FanmentoTests waitForCompletion:.2];
    }
    NSAssert(YES, @"");//did not crash
}

@end
