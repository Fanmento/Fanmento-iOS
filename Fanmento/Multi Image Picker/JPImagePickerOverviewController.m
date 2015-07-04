//
//  JPImagePickerOverviewController.m
//  JPImagePickerController
//
//  Created by Jeena on 11.11.09.
//  Copyright 2009 Jeena Paradies.
//  Licence: MIT-Licence
//
//  Made way better by Tj on 9/26/12

#import "JPImagePickerOverviewController.h"
#import "FNMFinalPictureDataSource.h"
#import "UIImageView+WebCache.h"

@implementation JPImagePickerOverviewController

@synthesize imagePickerController, detailController, scrollView;
@synthesize isMultiSelect = _isMultiSelect;
@synthesize multiImageArray = _multiImageArray;

#define PADDING_TOP 44
#define PADDING 5
#define THUMBNAIL_COLS 3

#define TJ_CHECK_TAG 420
#define CHECK_EDGE_LENGTH 27
#define CHECK_RECT CGRectMake(kJPImagePickerControllerThumbnailSizeWidth - CHECK_EDGE_LENGTH, kJPImagePickerControllerThumbnailSizeHeight - CHECK_EDGE_LENGTH, CHECK_EDGE_LENGTH, CHECK_EDGE_LENGTH)

#define MAX_IMAGES 5


- (id)initWithImagePickerController:(JPImagePickerController *)newImagePickerController {
    if (self = [super initWithNibName:@"JPImagePickerOverviewController" bundle:nil]) {
        // Custom initialization
		imagePickerController = newImagePickerController;
        [imagePickerController retain];
        
        _isMultiSelect = YES;
    }
    return self;
}

- (void)dealloc {
	[imagePickerController release];
	[detailController release];
	[scrollView release];
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (_isMultiSelect) {
        _multiImageArray = [[NSMutableArray alloc]init];
    }
    
	[self setImagePickerTitle:imagePickerController.imagePickerTitle];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelPicking:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadDataForGrid];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self clearGrid];
}

- (void)reloadDataForGrid
{
    [self clearGrid];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self loadGrid];
    });
}

- (void)clearGrid
{
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_multiImageArray removeAllObjects];
}

- (void)loadGrid
{
    VILoaderImageView *button;
	UIImage *thumbnail;
	int images_count = [imagePickerController.dataSource numberOfImagesInImagePicker:imagePickerController];
	
	for (int i=0; i<images_count; i++) {
		thumbnail = [imagePickerController.dataSource imagePicker:imagePickerController thumbnailForImageNumber:i];
		
		button = [[VILoaderImageView alloc]init];
		button.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonTouched:)];
        [tap setNumberOfTapsRequired:1];
        [tap setNumberOfTouchesRequired:1];
		[button addGestureRecognizer:tap];
        
		button.tag = i;
		button.frame = CGRectMake(kJPImagePickerControllerThumbnailSizeWidth * (i % THUMBNAIL_COLS) + PADDING * (i % THUMBNAIL_COLS) + PADDING,
								  kJPImagePickerControllerThumbnailSizeHeight * (i / THUMBNAIL_COLS) + PADDING * (i / THUMBNAIL_COLS) + PADDING + PADDING_TOP,
								  kJPImagePickerControllerThumbnailSizeWidth,
								  kJPImagePickerControllerThumbnailSizeHeight);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [button setContentMode:UIViewContentModeScaleAspectFill];
            
            if ([thumbnail isKindOfClass:[UIImage class]]) {
                [button setImage:thumbnail];
            }else{

                [button setImageWithURL:[NSString stringWithFormat:@"%@=s200",(NSString*)thumbnail]];
            }
            
            UIImageView*checkImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unchecked_circle"]];
            [checkImage setTag:TJ_CHECK_TAG];
            [checkImage setFrame:CHECK_RECT];
            [button addSubview:checkImage];
            [scrollView addSubview:button];
        });
		
	}
	
	int rows = images_count / THUMBNAIL_COLS;
	if (((float)images_count / THUMBNAIL_COLS) - rows != 0) {
		rows++;
	}
	int height = kJPImagePickerControllerThumbnailSizeHeight * rows + PADDING * rows + PADDING + PADDING_TOP;
	
    dispatch_async(dispatch_get_main_queue(), ^{
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
        scrollView.clipsToBounds = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoPickerControllerLoadComplete" object:self];
    });
}

- (void)setImagePickerTitle:(NSString *)newTitle {
	self.navigationItem.title = newTitle;
}

- (NSString *)imagePickerTitle {
	return self.navigationItem.title;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)cancelPicking:(id)sender {
    if (_isMultiSelect) {
        
        if ([imagePickerController.delegate respondsToSelector:@selector(imagePicker:didFinishPickingWithImageNumbers:)]) {
            
            [imagePickerController.delegate imagePicker:imagePickerController didFinishPickingWithImageNumbers:self.multiImageArray];
        }
        
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:imagePickerController.originalStatusBarStyle animated:YES];
        [imagePickerController.delegate imagePickerDidCancel:imagePickerController];
    }
}


- (void)buttonTouched:(UIGestureRecognizer *)sender {
    
    if (_isMultiSelect) {
        [self applyCheckAndAddImageToReturnList:(UIView*)sender.view];
    }else{
        [self performSelector:@selector(pushDetailViewWithSender:) withObject:sender.view afterDelay:0];
    }
}


- (void)applyCheckAndAddImageToReturnList:(VILoaderImageView *)imageButton
{
    
    if ([_multiImageArray containsObject:@(imageButton.tag)]) {
        [_multiImageArray removeObject:@(imageButton.tag)];
        if ([imageButton viewWithTag:TJ_CHECK_TAG]) {
            [[imageButton viewWithTag:TJ_CHECK_TAG] removeFromSuperview];
        }
        UIImageView*checkImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unchecked_circle"]];
        [checkImage setTag:TJ_CHECK_TAG];
        [checkImage setFrame:CHECK_RECT];
        [imageButton addSubview:checkImage];
    }else if(_multiImageArray.count < MAX_IMAGES){
        [_multiImageArray addObject:@(imageButton.tag)];
        if ([imageButton viewWithTag:TJ_CHECK_TAG]) {
            [[imageButton viewWithTag:TJ_CHECK_TAG] removeFromSuperview];
        }
        UIImageView*checkImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checked_circle"]];
        [checkImage setTag:TJ_CHECK_TAG];
        [checkImage setFrame:CHECK_RECT];
        [imageButton addSubview:checkImage];
    }else if(_multiImageArray.count == MAX_IMAGES){
        [[[UIAlertView alloc] initWithTitle:@"Photo Limit"
                                    message:[NSString stringWithFormat:@"The maximum number of photos that can be uploaded at once is %d", MAX_IMAGES]
                                   delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles: nil] show];
    }

    
    
}

- (void)pushDetailViewWithSender:(VILoaderImageView *)sender {
	if (detailController == nil) {
		detailController = [[JPImagePickerDetailController alloc] initWithOverviewController:self];
	}
	
	detailController.imageNumber = sender.tag;
	[imagePickerController.modalNavigationController pushViewController:detailController animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end
