//
//  UIImage+ContextAspectScale.h
//  Fanmento
//
//  Created by teejay on 9/22/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ContextAspectScale)
- (UIImage *)imageScaledToSize:(CGSize)size;
- (UIImage *)imageScaledToFitSize:(CGSize)size;
@end
