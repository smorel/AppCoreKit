//
//  CKSharedDisplayLink.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKSharedDisplayLink;

@protocol CKSharedDisplayLinkDelegate

- (void)sharedDisplayLinkDidRefresh:(CKSharedDisplayLink*)displayLink;

@end



@interface CKSharedDisplayLink : NSObject

+ (void)registerHandler:(id<CKSharedDisplayLinkDelegate>)handler;
+ (void)unregisterHandler:(id<CKSharedDisplayLinkDelegate>)handler;

@end
