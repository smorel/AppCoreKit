//
//  CKImageLoader.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageLoader.h"
#import "UIImage+Transformations.h"
#import "CKLocalization.h"
#import "CKDebug.h"
#import "RegexKitLite.h"

NSString * const CKImageLoaderErrorDomain = @"CKImageLoaderErrorDomain";


@interface CKWebRequest ()
@property (nonatomic, retain) NSURLConnection *connection;
@end


@interface CKImageLoader ()
@property (nonatomic, retain) CKWebRequest *request;

- (void)didReceiveValue:(UIImage*)image error:(NSError*)error cached:(BOOL)cached;
@end

//

@implementation CKImageLoader {
	id _delegate;
	CKWebRequest *_request;
	NSURL *_imageURL;
    dispatch_queue_t _postProcessQueue;
}

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize imageURL = _imageURL;
@synthesize completionBlock = _completionBlock;
@synthesize errorBlock = _errorBlock;

- (id)initWithDelegate:(id)delegate {
	if (self = [super init]) {
		self.delegate = delegate;
		//self.imageSize = CGSizeZero;
	}
	return self;
}

- (void)dealloc {
    if(_postProcessQueue){
        dispatch_release(_postProcessQueue);
    }
	[self cancel];
	self.imageURL = nil;
    [_completionBlock release];
    [_errorBlock release];
    [_postProcess release];
	[super dealloc];
}

#pragma mark Public API

- (void)loadImageWithContentOfURL:(NSURL *)url {
	[self cancel];
	self.imageURL = url;
	
    //CHECK if url is web or disk and load from disk if needed ...
    if([self.imageURL isFileURL]){
        if(![[NSFileManager defaultManager] fileExistsAtPath:[self.imageURL path]] ){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_(@"Could not find image file on disk") forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:CKImageLoaderErrorDomain code:1 userInfo:userInfo];
            if(_errorBlock){
                _errorBlock(self,error);
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didFailWithError:)]) {
                [self.delegate imageLoader:self didFailWithError:error];
            }
            CKDebugLog(@"Could not find image file on disk %@",self.imageURL);
        }
        else{
            UIImage *image = [UIImage imageWithContentsOfFile:[self.imageURL path]];
            if(image.scale != [[UIScreen mainScreen]scale]){
                image = [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen]scale] orientation:image.imageOrientation];
            }
            [self didFetchImage:image fromCache:YES];
        }
    }
    else if([[self.imageURL scheme] isMatchedByRegex:@"^(http|https)$"]){
        //__block CKImageLoader *bSelf = self;
        self.request = [CKWebRequest scheduledRequestWithURL:url completion:^(id object, NSURLResponse *response, NSError * error) {
            [self didReceiveValue:object error:error cached:(self.request.connection == nil)];
            self.request = nil;
        }];
    }
}

- (void)didFetchImage:(UIImage*)image fromCache:(BOOL)cache{
    if(!self.postProcess){
        [self didCompleteWithImage:image fromCache:cache];
    }else{
        if(!_postProcessQueue){
            _postProcessQueue = dispatch_queue_create("CKImageLoad_postProcess", 0);
        }
        dispatch_async(_postProcessQueue, ^{
            UIImage* transformed = self.postProcess(image);
            [self didCompleteWithImage:transformed fromCache:cache];
        });
    }
}

- (void)didCompleteWithImage:(UIImage*)image fromCache:(BOOL)cache{
    if (image) {
        void(^execute)() = ^(){
            if(_completionBlock){
                _completionBlock(self, image, YES);
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didLoadImage:cached:)]) {
                [self.delegate imageLoader:self didLoadImage:image cached:cache];
            }
        };
        
         if(dispatch_get_current_queue() == dispatch_get_main_queue()){
            execute();
         }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                execute();
            });
        }
    }
}

- (void)cancel {
    [self.request cancel];
    self.request = nil;
}

- (void)didReceiveValue:(UIImage*)image error:(NSError*)error cached:(BOOL)cached {
	if ([image isKindOfClass:[UIImage class]]) {
        [self didFetchImage:image fromCache:cached];
	} 
    else if (error) {
        if(_errorBlock){
            _errorBlock(self,error);
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didFailWithError:)]) {
            [self.delegate imageLoader:self didFailWithError:error];
        }
    }
    else{
		// Throws an error if the value is not an image
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_(@"Did not receive an image") forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:CKImageLoaderErrorDomain code:0 userInfo:userInfo];
        if(_errorBlock){
            _errorBlock(self,error);
        }
		if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didFailWithError:)]) {
            [self.delegate imageLoader:self didFailWithError:error];
        }
	}    
}

@end