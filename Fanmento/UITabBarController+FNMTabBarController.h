//
//  UITabBarController+FNMTabBarController.h
//  Fanmento
//
//  Created by Dean Andreakis Mac Mini Account on 9/8/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (FNMTabBarController)

// Create a custom image and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

@end
