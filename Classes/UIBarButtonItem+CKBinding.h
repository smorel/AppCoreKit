//
//  UIBarButtonItem+CKBinding.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-03-15.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNSObject+Bindings.h"

typedef void(^UIBarButtonItemExecutionBlock)();

@interface UIBarButtonItem (CKBinding)
@property(nonatomic,copy) UIBarButtonItemExecutionBlock block;

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style block:(void(^)())block;
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style block:(void(^)())block;
- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem block:(void(^)())block;

- (void)bindEventWithBlock:(void(^)())block;

@end
