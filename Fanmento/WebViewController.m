//
//  WebViewController.m
//  TA
//
//  Created by Anthony Alesia on 3/26/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"

@interface WebViewController ()
@property(strong, nonatomic) MBProgressHUD* hud;
@property(strong, nonatomic) NSURL *lastUrlLoaded;
@end

@implementation WebViewController

- (void)loadPageWithUrl:(NSURL *)url
{
    if (![url isEqual:self.lastUrlLoaded]) {
        [self.hud show:YES];

        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        self.lastUrlLoaded = url;
        self.loadSuccess = YES;
    }
}

- (void)hideToolbar
{
    [self.toolBar removeFromSuperview];
    CGRect webViewFrame = self.webView.frame;
    webViewFrame.size.height += self.toolBar.frame.size.height;
    self.webView.frame = webViewFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.loadSuccess = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = WEB_LOADING;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
    
    _lastButton.enabled = NO;
    _nextButton.enabled = NO;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = activityItem;

    [self.refreshButton setTarget:self];
    [self.refreshButton setAction:@selector(refreshPage:)];
    
    toolBarItems = [[NSMutableArray alloc] initWithArray:_toolBar.items];
    
    self.hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    
    self.hud.labelText = @"Loading...";
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.loadSuccess) {
        [self.webView reload];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)goForward:(id)sender 
{
    [self.webView goForward];
}

- (void)goBackwards:(id)sender 
{
    [self.webView goBack];
}

- (void)refreshPage:(id)sender 
{
    [self.webView reload];
}

- (void)stopLoadingPage:(id)sender 
{
    [self.webView stopLoading];
    [self.hud hide:YES];
}

- (void)sendToSafari:(id)sender 
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:@"Done", nil];
    [actionSheet showFromToolbar:self.toolBar];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (IBAction)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - web view delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{
    if ([self String:[[request URL] absoluteString] Contains:@"QP_BACK:"] ||
        [self String:[[request URL] absoluteString] Contains:@"QP_ERROR:"] ||
        [self String:[[request URL] absoluteString] Contains:@"QP_DONE:DONE"] ||
        [self String:[[request URL] absoluteString] Contains:@"QP_CANCEL:"]) {
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    
    DLog(@"request to load %@", request.URL.absoluteString);
    return YES;
}

-(BOOL)String:(NSString *)aString Contains:(NSString *)aSubString{
    NSRange range = [aString rangeOfString:aSubString  options:NSCaseInsensitiveSearch];
    if(range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
    self.loadSuccess = YES;
    self.navigationItem.title = WEB_LOADING;
    [activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [toolBarItems replaceObjectAtIndex:4 withObject:self.stopButton];
    self.toolBar.items = toolBarItems;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    self.loadSuccess = YES;
    [self.hud hide:YES];
    self.navigationItem.title = _webTitle;
    [activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _lastButton.enabled = self.webView.canGoBack;
    _nextButton.enabled = self.webView.canGoForward;
    [toolBarItems replaceObjectAtIndex:4 withObject:self.refreshButton];
    self.toolBar.items = toolBarItems;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
    self.loadSuccess = NO;
    [self.hud hide:YES];
    self.navigationItem.title = _webTitle;
    [activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [toolBarItems replaceObjectAtIndex:4 withObject:self.refreshButton];
    self.toolBar.items = toolBarItems;
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [self.hud hide:YES];
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
