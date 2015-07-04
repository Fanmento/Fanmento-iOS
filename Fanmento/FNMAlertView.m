//
//  FNMAlertView.m
//  Fanmento
//
//  Created by teejay on 4/10/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "FNMAlertView.h"

@implementation FNMAlertView

- (void)show
{
    if (![FNMAlertView alertDisplayed]) {
        [super show];
    }
}

+ (BOOL)alertDisplayed{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        for (UIView* view in subviews) {
            if ([view isKindOfClass:[UIAlertView class]]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
