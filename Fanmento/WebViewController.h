//
//  WebViewController.h
//  TA
//
//  Created by Anthony Alesia on 3/26/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WEB_LOADING     @"Loading..."

@interface WebViewController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate> {
    NSString *_webTitle;
    UIToolbar *_toolBar;
    UIBarButtonItem *_lastButton;
    UIBarButtonItem *_nextButton;
    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_stopButton;
    UIBarButtonItem *_actionButton;
    
    UIActivityIndicatorView *activityIndicator;
    NSMutableArray *toolBarItems;
}

@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *lastButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *nextButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;

@property(nonatomic, weak) IBOutlet UIButton *closeButton;
@property(nonatomic, weak) IBOutlet UIWebView *webView;
@property(nonatomic, retain) NSString *webTitle;

@property BOOL loadSuccess;

- (void)loadPageWithUrl:(NSURL *)url;
- (void)hideToolbar;

- (IBAction)goForward:(id)sender;
- (IBAction)goBackwards:(id)sender;
- (IBAction)refreshPage:(id)sender;
- (IBAction)stopLoadingPage:(id)sender;
- (IBAction)sendToSafari:(id)sender;

@end
