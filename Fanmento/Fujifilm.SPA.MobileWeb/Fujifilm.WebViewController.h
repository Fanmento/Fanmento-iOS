//
//  Fujifilm.WebViewController.h
//
//  Created by Jonathan Nick on 9/7/12.
//  Copyright (c) 2012 FUJIFILM North America Corp. All rights reserved.
//
//  Use of this code assumes agreement to the terms and conditions available here:
//  https://github.com/FujifilmDeveloperNetwork/Fujifilm.SPA.SampleApp.iOS/blob/master/README.md


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/** The __SpaMobileWebDelegagte__ protocol defines methods that your delegate object must implement to interact with the FujifilmWebViewController interface. The methods of this protocol notify your delegate when the user exits the SPA Mobile Web checkout flow for whatever reason.
 */
@protocol SpaMobileWebDelegate

/**
 Tells the delegate that how the user exited the SPA Mobile Web checkout flow.
 
 Control is passed back to your application once this delegate method is called.
 
 @param info user exit information.
 */
-(void) didUserExitWithInfo : (NSString *) info;
@end


/** This class facilitates image checkout with Fujifilm's Smart Publish api. Image upload is handled automatically.
 @note All images are resized, unless they are public urls.
 */
@interface FujifilmWebViewController : UIViewController <UIWebViewDelegate>{
    id <SpaMobileWebDelegate> delegate;
}

/**---------------------------------------------------------------------------------------
 * @name Configuring the ViewController
 *  ---------------------------------------------------------------------------------------
 */

/**
 The viewcontroller's delegate object.
 
 The delegate receives notification when the user exits the SPA Mobile Web checkout flow.
 
 @note This property must be set and should not be _nil_. You must provide a delegate that conforms to the SpaMobileWebDelegate protocol.
 */
@property (assign) id <SpaMobileWebDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain) UIView *activityIndicatorOverlay;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *environMent;
@property (nonatomic, retain) NSString *apikey;
@property (nonatomic, retain) NSString *productcode;
@property (nonatomic, retain) NSString *userid;
@property (nonatomic, assign) BOOL cacheUserinfo;
@property (nonatomic, assign) BOOL useeditor;
@property (nonatomic, retain) NSString *theme;
@property (nonatomic, assign) NSDictionary *styles;

/**---------------------------------------------------------------------------------------
 * @name Initializers
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a FujifilmWebViewController instance that handles all order checkout process.
 
 *Note* : All parameters are required.
 
 - Go to http://www.fujifilmapi.com to register for an apiKey.
 - Ensure you have the right apiKey for the right environment.
 
 @param apiKey Your Fujifilm SPA apiKey for your application.
 @param environment "test" or "live".
 @param enableeditor Boolean value indicating whether user can edit images or not.
 @return FujifilmWebViewController object with the options sent in.
 */
- (id)initWithOptions:(NSString *)apiKey environment:(NSString*)environment enableEditor:(BOOL)enableeditor;


/** Sends the images to the Fujifilm SPA Mobile Web checkout flow.
 
 Control is passed from your app to the SPA Mobile Web checkout flow, and images are uploaded automatically.
 
 - To show a list of all products send an empty string (@""). Product codes can be found at http://www.fujifilmapi.com.
 - Credit card information is *NEVER* saved.
 - All images are resized keeping aspect ratio.
 
 
 @param images NSArray of ALAsset, UIImage, NSString (public image urls http://), or FFImage.
 @param productCode Fujifilm SPA product code. To show a catalog list page use @"". To order an individual product and not show a catalog list page, use a product code. You can choose products and set pricing at www.fujifilmapi.com
 @param cacheaddressinfo Boolean value indicating whether user's billing and shipping information for future orders is saved or not (we do not save credit card numbers).
 @param userid Fujifilm SPA order originator userid (optional param, send in @"" if you don't use it).
 @warning Do not alter image orientation natively.
 
 */
- (void)checkOut:(id) images productCode:(NSString*)productCode cacheAddressInfo:(BOOL)cacheaddressinfo userID:(NSString*)userid;


/**---------------------------------------------------------------------------------------
 * @name Accessing the styling attributes
 *  ---------------------------------------------------------------------------------------
 */
/**
 Theme for the SPA Mobile Web checkout flow.
 
 Choose from :-
 
 - Default
 - DarkBlueGrey
 - DarkBlueTeal
 - Red
 - OrangeTeal
 - LightBlueGrey
 - White
 - Black
 
 @note If not set, Default theme is applied.
 */

- (void) setTheme:(NSString *)theme;

/** Optionally override theme styles.
 
 Key value dictionary of styles. Send in only those styles you want to override.
 
 Valid keys :-
 
 - EditPagePricingBarBackgroundEnd
 - EditPagePricingBarBackgroundStart
 - EditPricingBarFontColor
 - FooterBackgroundEnd
 - FooterBackgroundStart
 - FooterFontColor
 - HeaderBackgroundEnd
 - HeaderBackgroundStart
 - HeaderButtonBackgroundEnd
 - HeaderButtonBackgroundMiddle1
 - HeaderButtonBackgroundMiddle2
 - HeaderButtonBackgroundStart
 - HeaderButtonFontColor
 - HeaderFontColor
 - MainContentAreaBackground
 - MainContentAreaButtonBackgroundEnd
 - MainContentAreaButtonBackgroundMiddle1
 - MainContentAreaButtonBackgroundMiddle2
 - MainContentAreaButtonBackgroundStart
 - MainContentAreaButtonFontColor
 - MainContentAreaFontColor
 - ShowFooter
 
 @note  ShowFooter can only either be _true/false_.
 
 Values for all other keys can be RGB or Hex
 
 - RBG _rgb(192,192,192,1)_
 - Hex _#C0C0C0_
 */
- (void) setStyles:(NSDictionary *)styles;

@end

/** Custom image class to use when sending in image level properties.
 */
@interface FFImage:NSObject{
    id image;
    NSDictionary *properties;
}

/** Image to send to the SPA Mobile Web checkout flow.
 
 Valid types :-
 
 - ALAsset
 - UIImage
 - NSString
 */
@property (nonatomic, assign)  id image;

/** Key value encoded image level properties.
 
 Valid keys :-
 
 - TemplateName
 */
@property (nonatomic, retain)  NSDictionary * properties;
@end

