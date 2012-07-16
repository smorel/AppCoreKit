//
//  CKImageTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKImageTransformer.h"
#import "CKCache.h"

static NSOperationQueue *theSharedImageTransformQueue = nil;

@interface CKImageTransformer ()
@property (nonatomic, retain) NSURL* imageURL;
@end


@implementation CKImageTransformer
@synthesize imageLoader = _imageLoader;
@synthesize delegate = _delegate;
@synthesize originalImage = _originalImage;
@synthesize imageURL = _imageURL;

#pragma mark Initialization
-(void)dealloc{
	self.imageLoader = nil;
	self.delegate = nil;
	self.originalImage = nil;
	self.imageURL = nil;
	[super dealloc];
}

- (id)initWithDelegate:(id)theDelegate{
	[super init];
	self.delegate = theDelegate;
	return self;
}

#pragma mark Public API
- (void)imageForURL:(NSURL*)url{
	self.imageURL = url;
	
	//check in cache if the image exists
	UIImage* image = [[CKCache sharedCache] imageForKey:[self cacheKeyForUrl:url]];
	if(image){
		if(self.delegate){
			[self.delegate imageTransformer:self didTransformImage:image cached:YES];
		}
	}else{
		if(self.imageLoader == nil){
			self.imageLoader = [[[CKImageLoader alloc]initWithDelegate:self]autorelease];
			self.imageLoader.delegate = self;
		}
		[self.imageLoader loadImageWithContentOfURL:url];
	}
}

- (void)start {
	UIImage* transformedImage = [self transformImage:self.originalImage];
	[[CKCache sharedCache]setImage:transformedImage forKey:[self cacheKeyForUrl:self.imageURL]];
	if(self.delegate){
		[self.delegate imageTransformer:self didTransformImage:transformedImage cached:NO];
	}
}

- (void)cancel{
	if(self.imageLoader){
		[self.imageLoader cancel];
	}
	self.imageLoader = nil;
}
							
#pragma mark CKImageLoaderDelegate implementation	
- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached{
	self.originalImage = image;
	//add operation in queue
	if(theSharedImageTransformQueue == nil){
		theSharedImageTransformQueue = [[NSOperationQueue alloc] init];
		[theSharedImageTransformQueue setName:@"CKImageTransformer"];
		[theSharedImageTransformQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
	[theSharedImageTransformQueue addOperation:self];
}

- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error{
	if(self.delegate){
		[self.delegate imageTransformer:self didFailWithError:error];
	}
}

#pragma mark Overloadable functions
- (id)cacheKeyForUrl:(NSURL*)url{
	return [NSString stringWithFormat:@"%@",url];
}

- (UIImage*)transformImage:(UIImage*)image{
	return image;
}

@end
