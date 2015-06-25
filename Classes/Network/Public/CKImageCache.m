//
//  CKImageViewCache.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-23.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKImageCache.h"
#import "CKImageLoader.h"

@interface CKImageCacheItem : NSObject
@property(nonatomic,retain) NSMutableSet* handlers;
@property(nonatomic,retain) UIImage* image;
@end

@implementation CKImageCacheItem

- (void)dealloc{
    [_handlers release];
    [_image release];
    [super dealloc];
}

- (instancetype)init{
    self = [super init];
    self.handlers = [NSMutableSet set];
    return self;
}

- (void)registerHandler:(id)handler{
    [self.handlers addObject:[NSValue valueWithNonretainedObject:handler]];
}

- (void)unregisterHandler:(id)handler{
    [self.handlers removeObject:[NSValue valueWithNonretainedObject:handler]];
}

@end

@interface CKRemoteImageCacheItem : CKImageCacheItem<CKImageLoaderDelegate>
@property(nonatomic,retain) CKImageLoader* imageLoader;
@property(nonatomic,retain) NSURL* imageURL;
@end

@implementation CKRemoteImageCacheItem

- (void)dealloc{
    _imageLoader.delegate = nil;
    [_imageLoader cancel];
    [_imageLoader release];
    [_imageURL release];
    [super dealloc];
}

- (void)registerDelegate:(id<CKImageCacheDelegate>)delegate{
    [self registerHandler:delegate];
    
    if(self.imageLoader == nil && self.image == nil){
        [self startLoading];
    }else if(self.image){
        [delegate imageWasAlreadyFetched:self.image];
    }
}

- (void)unregisterDelegate:(id<CKImageCacheDelegate>)delegate{
    [self unregisterHandler:delegate];
    
    if(self.handlers.count == 0){
        [self stopLoading];
    }
}

- (void)reload{
    [self startLoading];
}

- (void)startLoading{
    if([self.imageURL isFileURL]){
        self.image = [UIImage imageWithContentsOfFile:[self.imageURL path]];
        
        for(NSValue* value in self.handlers){
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
        for(NSValue* value in self.handlers){
            id<CKImageCacheDelegate> delegate = [value nonretainedObjectValue];
            [delegate didFetchImage:image];
        }
    });
    self.imageLoader = nil;
}

- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error{
    for(NSValue* value in self.handlers){
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
    CKRemoteImageCacheItem* item = [self.items objectForKey:[url path]];
    if(item){
        [item registerDelegate:delegate];
    }else{
        CKRemoteImageCacheItem* item = [[[CKRemoteImageCacheItem alloc]init]autorelease];
        item.imageURL = url;
        [self.items setObject:item forKey:[url path]];
        
        [item registerDelegate:delegate];
    }
}

- (void)unregisterDelegate:(id<CKImageCacheDelegate>)delegate withImageURL:(NSURL*)url{
    CKRemoteImageCacheItem* item = [self.items objectForKey:[url path]];
    if(item){
        [item unregisterDelegate:delegate];
        
        if(item.handlers.count == 0){
            [self.items removeObjectForKey:[url path]];
        }
    }
}

- (void)reloadImageAtUrl:(NSURL*)url{
    CKRemoteImageCacheItem* item = [self.items objectForKey:[url path]];
    if(item){
        [item reload];
    }
}

- (UIImage*)imageWithUrl:(NSURL*)url{
    CKRemoteImageCacheItem* item = [self.items objectForKey:[url path]];
    if(!item)
        return nil;
    return item.image;
}

- (void)registerHandler:(id)handler image:(UIImage*)image withIdentifier:(NSString*)identifier{
    CKImageCacheItem* item = [self.items objectForKey:identifier];
    if(item){
        [item registerHandler:handler];
        item.image = image;
    }else{
        CKImageCacheItem* item = [[[CKImageCacheItem alloc]init]autorelease];
        item.image = image;
        [self.items setObject:item forKey:identifier];
        
        [item registerHandler:handler];
    }
}

- (void)unregisterHandler:(id)handler withIdentifier:(NSString*)identifier{
    CKImageCacheItem* item = [self.items objectForKey:identifier];
    if(item){
        [item unregisterHandler:handler];
        
        if(item.handlers.count == 0){
            [self.items removeObjectForKey:identifier];
        }
    }
}

- (UIImage*)imageWithIdentifier:(NSString*)identifier{
    CKImageCacheItem* item = [self.items objectForKey:identifier];
    if(!item)
        return nil;
    return item.image;
}


- (UIImage*)findOrCreateImageWithHandler:(id)handler
          handlerCacheIdentifierProperty:(NSString*)keypath
                         cacheIdentifier:(NSString*)cacheIdentifier
                      generateImageBlock:(UIImage*(^)())generateImageBlock{
    
    NSString* previousCacheIdentifier = [[handler valueForKeyPath:keypath] retain];
    
    if(![previousCacheIdentifier isEqualToString:cacheIdentifier]){
        [handler setValue:cacheIdentifier forKeyPath:keypath];
        
        [[CKImageCache sharedInstance]unregisterHandler:handler withIdentifier:previousCacheIdentifier];
    }
    
    [previousCacheIdentifier release];
    
    UIImage* image = [[CKImageCache sharedInstance]imageWithIdentifier:cacheIdentifier];
    if(!image){
        image = generateImageBlock();
    }
    
    [[CKImageCache sharedInstance]registerHandler:handler image:image withIdentifier:cacheIdentifier];
    return image;
}

@end
