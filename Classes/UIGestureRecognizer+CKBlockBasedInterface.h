//
//  UIGestureRecognizer+CKBlockBasedInterface.h
//  CloudKit
//
//  Created by Martin Dufort on 12-06-05.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (CKBlockBasedInterface) <UIGestureRecognizerDelegate>
@property(nonatomic,retain) NSArray* allowedSimultaneousRecognizers;

- (id)initWithBlock:(void(^)(UIGestureRecognizer* gestureRecognizer))block;
- (id)initWithBlock:(void(^)(UIGestureRecognizer* gestureRecognizer))block shouldBeginBlock:(BOOL(^)(UIGestureRecognizer* gestureRecognizer))shouldBeginBlock;

- (void)cancel;

@end
