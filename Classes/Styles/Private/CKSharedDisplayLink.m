//
//  CKSharedDisplayLink.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSharedDisplayLink.h"
#import "NSObject+Singleton.h"

@interface CKSharedDisplayLink()
@property(nonatomic,retain) NSMutableSet* handlers;
@property(nonatomic,retain) CADisplayLink* displayLink;
@end

@implementation CKSharedDisplayLink

- (void)dealloc{
    [_handlers release];_handlers = nil;
    [_displayLink release]; _displayLink = nil;
    [super dealloc];
}

+ (void)registerHandler:(id<CKSharedDisplayLinkDelegate>)handler{
    CKSharedDisplayLink* dl = [CKSharedDisplayLink sharedInstance];
    if(!dl.handlers){
        dl.handlers = [NSMutableSet set];
    }
    
    [dl.handlers addObject:[NSValue valueWithNonretainedObject:handler]];
    if(dl.handlers.count == 1){
        [dl start];
    }
}

+ (void)unregisterHandler:(id<CKSharedDisplayLinkDelegate>)handler{
    CKSharedDisplayLink* dl = [CKSharedDisplayLink sharedInstance];
    if(!dl.handlers)
        return;
    
    [dl.handlers removeObject:[NSValue valueWithNonretainedObject:handler]];
    if(dl.handlers.count == 0){
        // [dl stop];
    }
}

- (void)start{
    self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(update:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop{
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_displayLink invalidate];
    [_displayLink release];
    _displayLink = nil;
}

- (void)update:(CADisplayLink *)sender{
    for(NSValue* v in self.handlers){
        id<CKSharedDisplayLinkDelegate> handler = [v nonretainedObjectValue];
        [handler sharedDisplayLinkDidRefresh:self];
    }
}

@end
