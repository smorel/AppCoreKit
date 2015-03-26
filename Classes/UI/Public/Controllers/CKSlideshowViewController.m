//
//  CKSlideShowViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKSlideShowViewController.h"
#import "NSObject+Bindings.h"
#import "CKArrayCollection.h"
#import "CKImageView.h"

@interface CKSlideShowViewController ()
- (CKReusableViewControllerFactory*)defaultItemForURL;
@property (nonatomic, assign) BOOL controlsAreDisplayed;
- (void)updateTitle;

@end

@implementation CKSlideShowViewController
@synthesize controlsAreDisplayed = _controlsAreDisplayed;
@synthesize shouldHideControls = _shouldHideControls;
@synthesize overrideTitleToDisplayCurrentPage;

- (void)postInit{
    [super postInit];
    _controlsAreDisplayed = NO;
    _shouldHideControls = YES;
    self.overrideTitleToDisplayCurrentPage = YES;
    
    __block CKSlideShowViewController* bself = self;
    [NSObject beginBindingsContext:[NSString stringWithFormat:@"<%@>_internal",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
    [self bind:@"currentPage" withBlock:^(id value) {
        [bself updateTitle];
    }];
    [NSObject endBindingsContext];
}

- (void)updateTitle {
    if(!self.overrideTitleToDisplayCurrentPage)
        return;
    
    NSUInteger count = [self numberOfObjectsForSection:0];
    NSInteger index = [self currentPage];
    self.title = [NSString stringWithFormat:_(@"%d of %d"), index+1, count];
} 


+ (id)slideShowControllerWithCollection:(CKCollection *)collection{
    return [[[[self class]alloc]initWithCollection:collection]autorelease];
}

+ (id)slideShowControllerWithCollection:(CKCollection *)collection factory:(CKCollectionCellControllerFactory*)factory startAtIndex:(NSInteger)startIndex{
    return [[[[self class]alloc]initWithCollection:collection factory:factory startAtIndex:startIndex]autorelease];
}

+ (id)slideShowControllerWithCollection:(CKCollection *)collection startAtIndex:(NSInteger)startIndex{
    return [[[[self class]alloc]initWithCollection:collection startAtIndex:startIndex]autorelease];
    
}

+ (id)slideShowControllerWithImagePaths:(NSArray*)imagePaths startAtIndex:(NSInteger)startIndex{
    return [[[[self class]alloc]initWithImagePaths:imagePaths startAtIndex:startIndex]autorelease];
}

+ (id)slideShowControllerWithImageURLs:(NSArray*)imageURLs startAtIndex:(NSInteger)startIndex{
    return [[[[self class]alloc]initWithImageURLs:imageURLs startAtIndex:startIndex]autorelease];
}

- (id)initWithCollection:(CKCollection *)collection{
    return [self initWithCollection:collection startAtIndex:0];
}

- (id)initWithCollection:(CKCollection *)collection startAtIndex:(NSInteger)startIndex{
    CKCollectionCellControllerFactory* factory = [CKCollectionCellControllerFactory factory];
    [factory addItem:[self defaultItemForURL]];
    return [self initWithCollection:collection factory:factory startAtIndex:startIndex];
}

- (id)initWithCollection:(CKCollection *)collection factory:(CKCollectionCellControllerFactory*)factory startAtIndex:(NSInteger)startIndex{
    self = [self initWithCollection:collection factory:factory];
    self.indexPathToReachAfterRotation = [NSIndexPath indexPathForRow:startIndex inSection:0];
    return self;
}

- (id)initWithImagePaths:(NSArray*)imagePaths startAtIndex:(NSInteger)startIndex{
    NSMutableArray* urls = [NSMutableArray array];
    for(NSString* path in imagePaths){
        [urls addObject:[NSURL URLWithString:path]];
    }
    
    return [self initWithImageURLs:urls startAtIndex:startIndex];
}

- (id)initWithImageURLs:(NSArray*)imageURLs startAtIndex:(NSInteger)startIndex{
    CKArrayCollection* collection = [[[CKArrayCollection alloc]init]autorelease];
    [collection addObjectsFromArray:imageURLs];
    
    return [self initWithCollection:collection startAtIndex:startIndex];
}

- (CKCollectionCellControllerFactoryItem*)defaultItemForURL{
#define ImageViewTag 55534
    
    CKCollectionCellControllerFactoryItem* item = [CKCollectionCellControllerFactoryItem itemForObjectOfClass:[NSURL class] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
        CKTableViewCellController* controller = [CKTableViewCellController cellController];
        controller.name = @"CKSlideshowControllerURLCell";
        controller.flags = CKItemViewFlagNone;
        
        [controller setInitBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
            controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CKImageView* imageView = [[[CKImageView alloc]initWithFrame:controller.tableViewCell.contentView.bounds]autorelease];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.tag = ImageViewTag;
            imageView.spinnerStyle = UIActivityIndicatorViewStyleWhiteLarge;
            imageView.imageViewContentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            [controller.tableViewCell.contentView addSubview:imageView];
        }];
        
        [controller setSetupBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
            CKImageView* imageView = (CKImageView*)[cell.contentView viewWithTag:ImageViewTag];
            NSURL* url = (NSURL*)controller.value;
            imageView.imageURL = url;
        }];
        
        [controller setSizeBlock:^CGSize(CKTableViewCellController *controller) {
            CGSize tableViewSize = [controller parentTableView].frame.size;
            if([(CKTableCollectionViewController*)[controller parentTableViewController] orientation] == CKTableViewOrientationPortrait){
                return CGSizeMake(tableViewSize.width, tableViewSize.height);
            }
            else{
                return CGSizeMake(tableViewSize.height, tableViewSize.width);
            }
            return CGSizeMake(0,0);
        }];
        
        return controller;
    }];
    
#undef ImageViewTag
    
    return item;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.pagingEnabled = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CKSlideShowViewControllerArrowLeft.png"] style:UIBarButtonItemStylePlain target:self action:@selector(previousImage:)];
	UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CKSlideShowViewControllerArrowRight.png"] style:UIBarButtonItemStylePlain target:self action:@selector(nextImage:)];
	[self setToolbarItems:[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						   previousButton,
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						   nextButton,
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						   nil] 
				 animated:YES];
    [previousButton release];
    [nextButton release];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    self.navigationItem.titleView = nil;
    
    self.controlsAreDisplayed = YES;
    if ([self numberOfObjectsForSection:0] > 1) { 
		[self.navigationController setToolbarHidden:NO animated:animated];
	}
    
    [self updateTitle];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_shouldHideControls) {
		[self performSelector:@selector(hideControls) withObject:nil afterDelay:5];
	}
}


- (void)showControls {	
	if (self.navigationController.navigationBar.alpha == 0) {
		[UIView beginAnimations:nil context:nil];
		self.navigationController.navigationBar.alpha = 1;
		self.navigationController.toolbar.alpha = 1;
		[UIView commitAnimations];
	}
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self];	
	[self performSelector:@selector(hideControls) withObject:nil afterDelay:5];
    
    self.controlsAreDisplayed = YES;
}

- (void)hideControls {
    if(!_shouldHideControls)
        return;
    
	if (!_controlsAreDisplayed) 
        return;
    
	[UIView beginAnimations:nil context:nil];
	self.navigationController.navigationBar.alpha = 0;
	self.navigationController.toolbar.alpha = 0;
	[UIView commitAnimations];
    
    self.controlsAreDisplayed = NO;
}

- (void)nextImage:(id)sender {
    NSInteger currentImage = [self currentPage];
    if(currentImage >= ([self numberOfObjectsForSection:0] -1))
        return;
    
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentImage+1 inSection:0] animated:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];	
	[self performSelector:@selector(hideControls) withObject:nil afterDelay:5];
}

- (void)previousImage:(id)sender {
    NSInteger currentImage = [self currentPage];
    if(currentImage == 0)
        return;
    
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentImage-1 inSection:0] animated:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];	
	[self performSelector:@selector(hideControls) withObject:nil afterDelay:5];
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_shouldHideControls) {
        if (!self.controlsAreDisplayed){
            [self performSelector:@selector(showControls) withObject:nil afterDelay:0.5];
        }
        else {
            [self performSelector:@selector(hideControls) withObject:nil afterDelay:0.5];
        }
    }
    return [super tableView:tableView willSelectRowAtIndexPath:indexPath];
}

- (void)didEndUpdates{
    [super didEndUpdates];
    if ([self numberOfObjectsForSection:0] > 1) { 
		[self.navigationController setToolbarHidden:NO animated:YES];
	}
    else{
		[self.navigationController setToolbarHidden:YES animated:YES];
    }
    [self updateTitle];
}

@end
