//
//  FNMSettingsViewControllerTests.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 10/7/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMSettingsViewControllerTests.h"
#import <dlfcn.h>

@implementation FNMSettingsViewControllerTests


-(void)setUp
{
    appDelegate = [[UIApplication sharedApplication]delegate];
    dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);
}

//TS1.7 User selects Settings Screen
-(void)test00SettingsViewControllerAppears
{
    [events() sendTap:CGPointMake(220, 479)];
    [FanmentoTests waitForCompletion:4];
    NSAssert([appDelegate.tabBarController selectedIndex] == 3, @"Incorrect View Controller Selected");
}

//TS1.8 User selects Settings Screen
-(void)test01SettingsViewControllerAppears
{
    [events() sendTap:CGPointMake(220, 479)];//settings tab
    [FanmentoTests waitForCompletion:4];
    
    [events() sendTap:CGPointMake(160, 90)];//select "Send Feedback" buttton
    [FanmentoTests waitForCompletion:4];
    
    [events() sendTap:CGPointMake(20, 20)];//select "Cancel" button at top left of email draft screen
    [FanmentoTests waitForCompletion:4];
    
    [events() sendTap:CGPointMake(160, 330)];//select "Delete Draft" from action sheet popup
    [FanmentoTests waitForCompletion:4];
    
    NSAssert([appDelegate.tabBarController selectedIndex] == 3, @"Incorrect View Controller Selected");
}

-(void)tearDown
{
    
}

@end
