//
//  CKImageViewCache.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-23.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKImageCache.h"
#import <AppCoreKit/AppCoreKit.h>

@interface CKImageCacheItem : NSObject<CKImageLoaderDelegate>
@property(nonatomic,retain) CKImageLoader* imageLoader;
@property(nonatomic,retain) NSMutableArray* weakDelegates;
@property(nonatomic,retain) NSURL* imageURL;
@property(nonatomic,retain) UIImage* image;
@end

@implementation CKImageCacheItem

- (void)dealloc{
    [_imageLoader release];
    [_weakDelegates release];
    [_imageURL release];
    [_image release];
    [super dealloc];
}

- (instancetype)init{
    self = [super init];
    self.weakDelegates = [NSMutableArray array];
    return self;
}

- (void)registerDelegate:(id<CKImageCacheDelegate>)delegate{
    [self.weakDelegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    if(self.imageLoader == nil && self.image == nil){
        [self startLoading];
    }else if(self.image){
        [delegate imageWasAlreadyFetched:self.image];
    }
}

- (void)unregisterDelegate:(id<CKImageCacheDelegate>)delegate{
    [self.weakDelegates removeObject:[NSValue valueWithNonretainedObject:delegate]];
    if(self.weakDelegates.count == 0){
        [self stopLoading];
    }
}

- (void)reload{
    [self startLoading];
}

- (void)startLoading{
    if([self.imageURL isFileURL]){
        self.image = [UIImage imageWithContentsOfFile:[self.imageURL path]];
        
        for(NSValue* value in self.weakDelegates){
            id<CKImageCacheDelegate> delegate = [value nonretainedObjectValue];
            [delegate imageWasAlreadyFetched:self.image];
        }
    }else{
        self.imageLoader = [[CKImageLoader alloc]initWithDelegate:self];
        [self.imageLoader loadImageWithContentOfURL:self.imageURL];
    }
}

- (void)stopLoading{
    [self.imageLoader cancel];
}

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached{
    self.image = image;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for(NSValue* value in self.weakDelegates){
            id<CKImageCacheDelegate> delegate = [value nonretainedObjectValue];
            [delegate didFetchImage:image];
        }
    });
    self.imageLoader = nil;
}

- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error{
    for(NSValue* value in self.weakDelegates){
        id<CKImageCacheDelegate> delegate = [value nonretainedObjectValue];
        [delegate didFailFetchingImage:error];
    }
    
    self.imageLoader = nil;
}

@end




@interface CKImageCache()
@property(nonatomic,retain) NSMutableDictionary* items;
@end


@implementation CKImageCache

- (void)dealloc{
     [_items release];
    [super dealloc];
}

- (instancetype)init{
    self = [super init];
    self.items = [NSMutableDictionary dictionary];
    return self;
}

- (void)registerDelegate:(id<CKImageCacheDelegate>)delegate withImageURL:(NSURL*)url{
    CKImageCacheItem* item = [self.items objectForKey:url];
    if(item){
        [item registerDelegate:delegate];
    }else{
        CKImageCacheItem* item = [[[CKImageCacheItem alloc]init]autorelease];
        item.imageURL = url;
        [self.items setObject:item forKey:url];
        
        [item registerDelegate:delegate];
    }
}

- (void)unregisterDelegate:(id<CKImageCacheDelegate>)delegate withImageURL:(NSURL*)url{
    CKImageCacheItem* item = [self.items objectForKey:url];
    if(item){
        [item unregisterDelegate:delegate];
        
        if(item.weakDelegates.count == 0){
            [self.items removeObjectForKey:url];
        }
    }
}

- (void)reloadImageAtUrl:(NSURL*)url{
    CKImageCacheItem* item = [self.items objectForKey:url];
    if(item){
        [item reload];
    }
}

@end
