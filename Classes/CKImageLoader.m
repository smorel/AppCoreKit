//
//  CKImageLoader.m
//  CloudKit
//
//  Created by Olivier Collet on 10-07-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageLoader.h"
#import "CKUIImage+Transformations.h"
#import "CKLocalization.h"
#import "CKDebug.h"
#import "RegexKitLite.h"

NSString * const CKImageLoaderErrorDomain = @"CKImageLoaderErrorDomain";

@interface CKImageLoader ()
@property (nonatomic, retain) CKWebRequest *request;

- (void)didReceiveValue:(UIImage*)image error:(NSError*)error;
@end

//

@implementation CKImageLoader

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
	[self cancel];
	self.imageURL = nil;
    [_completionBlock release];
    [_errorBlock release];
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
            if (image) {
                if(_completionBlock){
                    _completionBlock(self,image,YES);
                }
                [self.delegate imageLoader:self didLoadImage:image cached:YES];
            }
        }
    }
    else if([[self.imageURL scheme] isMatchedByRegex:@"^(http|https)$"]){
        //__block CKImageLoader *bSelf = self;
        self.request = [CKWebRequest scheduledRequestWithURL:url completion:^(id object, NSURLResponse *response, NSError * error) {
            [self didReceiveValue:object error:error];
        }];
    }
}

- (void)cancel {
    [self.request cancel];
    self.request = nil;
}

- (void)didReceiveValue:(UIImage*)image error:(NSError*)error {
	if ([image isKindOfClass:[UIImage class]]) {
        if(_completionBlock){
            _completionBlock(self, image, YES);
        }
		if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didLoadImage:cached:)]) {
			[self.delegate imageLoader:self didLoadImage:image cached:NO];
		}
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