//
//  UITabBarController+FNMTabBarController.m
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/8/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "UITabBarController+FNMTabBarController.h"
#import "Constant.h"

@implementation UITabBarController (FNMTabBarController)

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(fingerTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
    
    UIImageView* dividerView1 = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tab-button-divider" ofType:@"png"]]];
    [self.view addSubview:dividerView1];
    dividerView1.frame = CGRectMake(63,  screenHeight()-self.tabBar.frame.size.height, 1, self.tabBar.frame.size.height);
    
    UIImageView* dividerView2 = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tab-button-divider" ofType:@"png"]]];
    [self.view addSubview:dividerView2];
    dividerView2.frame = CGRectMake(255, screenHeight()-self.tabBar.frame.size.height, 1, self.tabBar.frame.size.height);
}

- (void)fingerTapped
{
    self.selectedIndex = 1;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_FINGER_TAPPED object:self];
}

@end
