//
//  FNMGalleryViewControllerTests.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/16/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "FNMGalleryViewControllerTests.h"
#import <dlfcn.h>

@implementation FNMGalleryViewControllerTests

-(void)setUp
{
    appDelegate = [[UIApplication sharedApplication]delegate];
    dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);
}

-(void)tearDown
{
    
}

//TS1.1 Application Displays Template Gallery Screen
-(void)test00GalleryViewControllerAppears
{
    [events() sendTap:CGPointMake(100, 479)];
    [FanmentoTests waitForCompletion:4];
    NSAssert([appDelegate.tabBarController selectedIndex] == 1, @"Incorrect View Controller Selected");
}

//TS1.2 & TS1.3 Application Displays Template Details View (from fanmento test plan)
//uses the camera to take a picture
-(void)test01GalleryDetailViewAppears
{
    [events() sendTap:CGPointMake(100, 479)];//templates tab
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(100, 20)];//choose template in upper left of grid/table
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(250, 20)];//hit the front facing camera button
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(160, 260)];//dismiss the low res alert
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(160, 479)];//take a picture
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(300, 460)];//dismiss the help screen
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(300, 460)];//select the use button
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(281, 10)];//select the close (circle x) button
    [FanmentoTests waitForCompletion:5];
    NSAssert([appDelegate.tabBarController selectedIndex] == 0, @"Not on My Collections Tab");
}

//TS1.2 and TS1.4 Application Displays Template Details View (from fanmento test plan)
//uses Library button to choose picture
-(void)test02GalleryDetailViewAppears
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
    NSAssert([appDelegate.tabBarController selectedIndex] == 0, @"Not on My Collections Tab");
}

//TS1.5 User previews final picture (from fanmento test plan)
//uses the camera to take a picture and then scales/rotates the picture
-(void)test03GalleryDetailViewAppears
{
    [events() sendTap:CGPointMake(100, 479)];//templates tab
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(100, 20)];//choose template in upper left of grid/table
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(250, 20)];//hit the front facing camera button
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(160, 260)];//dismiss the low res alert
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(160, 479)];//take a picture
    [FanmentoTests waitForCompletion:5];
    
    [events() sendTap:CGPointMake(292, 8)];//select the close (circle x) button
    [FanmentoTests waitForCompletion:5];
    
    [events() sendPinchOpenWithStartPoint:CGPointMake(160, 160) endPoint:CGPointMake(160, 140) duration:3];
    [FanmentoTests waitForCompletion:5];
    
    [events() sendRotate:CGPointMake(160, 120) withRadius:40 rotation:25 duration:3 touchCount:10];
    [FanmentoTests waitForCompletion:5];
    
    [events() sendTap:CGPointMake(300, 460)];//select the use button
    [FanmentoTests waitForCompletion:5];
    [events() sendTap:CGPointMake(281, 10)];//select the close (circle x) button
    [FanmentoTests waitForCompletion:5];
    NSAssert([appDelegate.tabBarController selectedIndex] == 0, @"Not on My Collections Tab");
}
@end
