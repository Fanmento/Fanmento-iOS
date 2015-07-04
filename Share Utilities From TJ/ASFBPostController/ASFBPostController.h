//
//  Copyright (c) 2012 AppStair LLC. All rights reserved.
//  http://appstair.com
//

#import <UIKit/UIKit.h>

@interface ASFBPostController : UITableViewController

@property(nonatomic, retain) UIImage *originalImage;
@property(nonatomic, retain) UIImage *thumbnailImage;
@property(nonatomic, retain) UITextView *textView;
@property(nonatomic, retain) NSString *shareDefaulText;
@property(nonatomic, strong) id delegate;
@end
