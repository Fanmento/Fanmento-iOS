//
//  FNMFujifilmWebViewController.m
//  Fanmento
//
//  Created by Bill Werges on 7/8/13.
//  Copyright (c) 2013 VOKAL. All rights reserved.
//

#import "FNMFujifilmWebViewController.h"

#import "Constant.h"

@implementation FNMFujifilmWebViewController

- (id)init
{
    if(self = [super initWithOptions:FUJI_API_KEY
                         environment:FUJI_ENVIRONMENT
                        enableEditor:YES]) {
        self.styles = @{@"HeaderBackgroundStart": @"rgb(241,104,52)",
                        @"HeaderBackgroundEnd": @"rgb(221,84,30)",
                        @"HeaderButtonBackgroundStart": @"rgb(255,255,255)",
                        @"HeaderButtonBackgroundMiddle1": @"rgb(255,255,255)",
                        @"HeaderButtonBackgroundMiddle2": @"rgb(255,255,255)",
                        @"HeaderButtonBackgroundEnd": @"rgb(255,255,255)",
                        @"HeaderButtonFontColor":@"rgb(241,104,52)",
                        @"EditPagePricingBarBackgroundStart": @"rgb(139,141,138)",
                        @"EditPagePricingBarBackgroundEnd": @"rgb(61,61,61)",
                        @"MainContentAreaButtonBackgroundStart": @"rgb(240,103,51)",
                        @"MainContentAreaButtonBackgroundMiddle1": @"rgb(240,103,49)",
                        @"MainContentAreaButtonBackgroundMiddle2": @"rgb(231,94,40)",
                        @"MainContentAreaButtonBackgroundEnd": @"rgb(231,94,42)",
                        @"FooterBackgroundStart": @"rgb(235,233,234)",
                        @"FooterBackgroundEnd": @"rgb(199,197,198)",
                        @"FooterFontColor": @"rgb(145,145,145)"};
    }

    return self;
}

@end
